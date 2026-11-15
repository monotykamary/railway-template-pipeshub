#!/usr/bin/env python3
"""Authenticated KB upload, completed indexing, download, and original-ID persistence."""
import json,os,pathlib,secrets,time,urllib.request,urllib.error
base=os.environ.get('BASE_URL_PIPESHUB',os.environ['BASE_URL']).rstrip('/');phase=os.environ['SMOKE_PHASE'];assert phase in ('boot','upgrade','redeploy')
state=pathlib.Path(os.environ.get('SMOKE_STATE',os.path.join(os.environ.get('SUPERCOMPUTER_OUTPUT_DIR','.'),'smoke-state.json')))
def req(path,data=None,token=None,session=None,ctype='application/json'):
 headers={'Content-Type':ctype}
 if token:headers['Authorization']='Bearer '+token
 if session:headers['x-session-token']=session
 if isinstance(data,dict):data=json.dumps(data).encode()
 try:
  with urllib.request.urlopen(urllib.request.Request(base+path,data=data,headers=headers),timeout=180) as r:return r.status,r.read(),r.headers
 except urllib.error.HTTPError as e:return e.code,e.read(),e.headers
def api(path,data=None,**kw):
 status,body,h=req(path,data,**kw);assert 200<=status<300,(path,status);return json.loads(body),h
def find(value,key):
 if isinstance(value,dict):
  if key in value:return value[key]
  for v in value.values():
   result=find(v,key)
   if result is not None:return result
 if isinstance(value,list):
  for v in value:
   result=find(v,key)
   if result is not None:return result
 return None
email=os.environ['ADMIN_EMAIL'];password=os.environ['ADMIN_PASSWORD']
_,h=api('/api/v1/userAccount/initAuth',{'email':email})
status,_,_=req('/api/v1/userAccount/authenticate',{'method':'password','credentials':{'password':'invalid-validation-password'},'email':email},session=h['x-session-token']);assert status in (400,401,403),'invalid credentials accepted'
_,h=api('/api/v1/userAccount/initAuth',{'email':email})
login,_=api('/api/v1/userAccount/authenticate',{'method':'password','credentials':{'password':password},'email':email},session=h['x-session-token']);token=login['accessToken']
status,_,_=req('/api/v1/knowledgeBase/');assert status in (401,403),'anonymous KB access accepted'
if phase=='boot':
 assert not state.exists(),'refusing to replace original seed'
 marker='railway-proof-'+secrets.token_hex(9)
 kb,_=api('/api/v1/knowledgeBase/',{'kbName':marker},token=token)
 seed={'kb':kb['id'],'marker':marker,'filename':marker+'.txt'}
 boundary='railway'+secrets.token_hex(8);content=(marker+' is the immutable Railway document validation marker.\n').encode()
 metadata=json.dumps([{'file_path':seed['filename'],'last_modified':int(time.time()*1000)}])
 body=('--'+boundary+'\r\nContent-Disposition: form-data; name="files_metadata"\r\n\r\n'+metadata+'\r\n--'+boundary+'\r\nContent-Disposition: form-data; name="files"; filename="'+seed['filename']+'"\r\nContent-Type: text/plain\r\n\r\n').encode()+content+('\r\n--'+boundary+'--\r\n').encode()
 status,raw,_=req('/api/v1/knowledgeBase/'+seed['kb']+'/upload',body,token=token,ctype='multipart/form-data; boundary='+boundary);assert 200<=status<300,'upload failed'
 text=raw.decode();assert 'event: file:failed' not in text,'file processing failed'
 if text.lstrip().startswith('{'):events=[json.loads(text)]
 else:events=[json.loads(line[5:].strip()) for line in text.splitlines() if line.startswith('data:') and line[5:].strip()]
 ids=[find(e,'recordId') for e in events if find(e,'recordId')];assert ids,'upload did not return a record id'
 seed['record']=ids[0];seed['content']=content.decode();state.parent.mkdir(parents=True,exist_ok=True);state.write_text(json.dumps(seed));state.chmod(0o600)
else:
 assert state.exists(),'missing original document seed; refusing to reseed at '+phase
 seed=json.loads(state.read_text())
kb,_=api('/api/v1/knowledgeBase/'+seed['kb'],token=token);assert find(kb,'name')==seed['marker'],'original knowledge base missing'
deadline=time.monotonic()+600
while True:
 record,_=api('/api/v1/knowledgeBase/record/'+seed['record'],token=token)
 status=find(record,'indexingStatus')
 if status=='COMPLETED':break
 assert status not in ('FAILED','ERROR'),'indexing worker failed'
 assert time.monotonic()<deadline,'indexing did not complete'
 time.sleep(5)
status,raw,_=req('/api/v1/knowledgeBase/stream/record/'+seed['record'],token=token);assert status==200 and raw.decode()==seed['content'],'original document bytes not preserved'
print('PASS PipesHub auth, knowledge-base creation, file upload/indexing, original record and bytes:',phase)

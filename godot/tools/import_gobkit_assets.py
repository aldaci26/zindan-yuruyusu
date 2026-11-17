#!/usr/bin/env python3
"""Import Gobkit's CC0 animated creature/nature GLBs at a pinned revision."""
from __future__ import annotations
import concurrent.futures, hashlib, json, os, sys, time, urllib.error, urllib.request
from pathlib import Path

REPO="Ariescar/gobkit-free-assets"
COMMIT="4e73c68fa6e8ca9d948fcc0ce7215c830a022c3b"
ROOT=Path(__file__).resolve().parents[1]
DEST=ROOT/"assets"/"third_party"/"gobkit"

def get(url,token=""):
 headers={"User-Agent":"zindan-yuruyusu-cc0-import/1.0"}
 if token: headers["Authorization"]="Bearer "+token
 last=None
 for attempt in range(5):
  try:
   with urllib.request.urlopen(urllib.request.Request(url,headers=headers),timeout=90) as r: return r.read()
  except (urllib.error.URLError,TimeoutError) as e:
   last=e
   if attempt<4: time.sleep(2**attempt)
 raise RuntimeError(f"Download failed {url}: {last}")

def inspect_glb(data):
 if len(data)<20 or data[:4]!=b"glTF" or int.from_bytes(data[4:8],"little")!=2: raise RuntimeError("Invalid GLB v2")
 n=int.from_bytes(data[12:16],"little")
 doc=json.loads(data[20:20+n].decode("utf-8").rstrip("\x00 \r\n"))
 return {"animations":[a.get("name",f"animation_{i}") for i,a in enumerate(doc.get("animations",[]))],"skins":len(doc.get("skins",[])),"meshes":len(doc.get("meshes",[])),"materials":len(doc.get("materials",[]))}

def main():
 token=os.environ.get("GITHUB_TOKEN","")
 tree=json.loads(get(f"https://api.github.com/repos/{REPO}/git/trees/{COMMIT}?recursive=1",token))
 if tree.get("truncated"): raise RuntimeError("Gobkit source tree truncated")
 chosen=[e for e in tree.get("tree",[]) if e.get("type")=="blob" and (e["path"] in {"README.md","LICENSE"} or (e["path"].lower().endswith(".glb") and e["path"].split("/",1)[0] in {"animal","minion","nature"}))]
 if len([e for e in chosen if e["path"].lower().endswith(".glb")])<50: raise RuntimeError("Gobkit GLB set is unexpectedly incomplete")
 tasks=[]
 for e in chosen:
  tasks.append((e["path"],int(e["size"]),e["sha"]))
 manifest={"creator":"Gobkit / Alsomind Tech Co., Ltd.","license":"CC0-1.0","source_repository":f"https://github.com/{REPO}","source_commit":COMMIT,"source_readme":f"https://github.com/{REPO}/blob/{COMMIT}/README.md","source_license":f"https://github.com/{REPO}/blob/{COMMIT}/LICENSE","assets":[]}
 def download(task):
  path,size,blob=task
  data=get(f"https://raw.githubusercontent.com/{REPO}/{COMMIT}/{path}",token)
  if len(data)!=size: raise RuntimeError(f"Size mismatch: {path}")
  info=inspect_glb(data) if path.lower().endswith(".glb") else {}
  dest=DEST/path; dest.parent.mkdir(parents=True,exist_ok=True); dest.write_bytes(data)
  record={"path":path,"git_blob_sha":blob,"sha256":hashlib.sha256(data).hexdigest(),"size_bytes":len(data),"license":"CC0-1.0",**info}
  if path.startswith("animal/"):
   record["animation_segments"]={"fps":24,"idle":[0,29],"attack":[30,59],"dead":[60,89],"walk":[90,119]}
  elif path.startswith("minion/"):
   record["animation_segments"]={"fps":24,"idle":[0,29],"attack":[30,59],"dead":[60,89]}
  return record
 print(f"Downloading {len(tasks)} Gobkit files")
 with concurrent.futures.ThreadPoolExecutor(max_workers=12) as pool:
  for i,record in enumerate(pool.map(download,tasks),1):
   manifest["assets"].append(record)
   if i%10==0 or i==len(tasks): print(f"[{i}/{len(tasks)}] {record['path']}")
 manifest["summary"]={"file_count":len(manifest["assets"]),"glb_count":sum(x["path"].lower().endswith(".glb") for x in manifest["assets"]),"animated_glb_count":sum(bool(x.get("animations")) for x in manifest["assets"]),"total_bytes":sum(x["size_bytes"] for x in manifest["assets"])}
 (DEST/"ASSET_MANIFEST.json").write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
 print(json.dumps(manifest["summary"],indent=2))
if __name__=="__main__":
 try: raise SystemExit(main())
 except Exception as exc:
  print(f"GOBKIT IMPORT FAILED: {exc}",file=sys.stderr); raise

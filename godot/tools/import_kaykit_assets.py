#!/usr/bin/env python3
"""Import selected KayKit CC0 glTF/GLB files, referenced maps and notices."""
from __future__ import annotations
import concurrent.futures, hashlib, json, os, sys, time, urllib.error, urllib.request
from pathlib import Path, PurePosixPath

ROOT=Path(__file__).resolve().parents[1]
DEST=ROOT/"assets"/"third_party"/"kaykit"
SOURCES={
 "adventurers":{"repo":"KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0","commit":"672074b73ba276876a19e8816ecdc5241817ab47","addon":"kaykit_character_pack_adventures","folders":["Characters/gltf/","Assets/gltf/"],"ext":{".glb",".gltf",".bin",".png"}},
 "skeletons":{"repo":"KayKit-Game-Assets/KayKit-Character-Pack-Skeletons-1.0","commit":"15b62b9bad122f72926c10fb14d622c73819fa54","addon":"kaykit_character_pack_skeletons","folders":["Characters/gltf/","Assets/gltf/"],"ext":{".glb",".gltf",".bin",".png"}},
 "dungeon":{"repo":"KayKit-Game-Assets/KayKit-Dungeon-Remastered-1.0","commit":"b0ca9bd96a8072ab36a3a5464f00ed1e06a16d07","addon":"kaykit_dungeon_remastered","folders":["Assets/gltf/","Assets/texture/"],"ext":{".glb",".png"}},
}
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
def glb_info(data):
 if len(data)<20 or data[:4]!=b"glTF" or int.from_bytes(data[4:8],"little")!=2: raise RuntimeError("Invalid glTF 2.0 binary")
 n=int.from_bytes(data[12:16],"little")
 doc=json.loads(data[20:20+n].decode("utf-8").rstrip("\x00 \r\n"))
 return {"animations":[a.get("name",f"animation_{i}") for i,a in enumerate(doc.get("animations",[]))],"skins":len(doc.get("skins",[])),"meshes":len(doc.get("meshes",[])),"materials":len(doc.get("materials",[]))}
def main():
 token=os.environ.get("GITHUB_TOKEN","")
 tasks=[]; manifest={"license":"CC0-1.0","creator":"Kay Lousberg / KayKit","sources":{},"assets":[]}
 for slug,spec in SOURCES.items():
  repo,commit,addon=spec["repo"],spec["commit"],spec["addon"]
  tree=json.loads(get(f"https://api.github.com/repos/{repo}/git/trees/{commit}?recursive=1",token))
  if tree.get("truncated"): raise RuntimeError(f"Truncated source tree: {repo}")
  prefix=f"addons/{addon}/"
  chosen=[]
  for e in tree.get("tree",[]):
   if e.get("type")!="blob": continue
   p=e["path"]
   if p in ("README.md","LICENSE.txt"): chosen.append(e); continue
   if not p.startswith(prefix): continue
   rel=p[len(prefix):]
   if any(rel.startswith(x) for x in spec["folders"]) and PurePosixPath(p).suffix.lower() in spec["ext"]: chosen.append(e)
  if not any(x["path"].lower().endswith(".glb") for x in chosen): raise RuntimeError(f"No GLB found in {repo}")
  manifest["sources"][slug]={"repository":f"https://github.com/{repo}","commit":commit,"license":"CC0-1.0","readme":f"https://github.com/{repo}/blob/{commit}/README.md","license_file":f"https://github.com/{repo}/blob/{commit}/LICENSE.txt","file_count":len(chosen)}
  for e in chosen:
   p=e["path"]
   rel=f"{slug}/{p}" if p in ("README.md","LICENSE.txt") else f"{slug}/{p[len(prefix):]}"
   tasks.append((repo,commit,p,rel,int(e["size"]),e["sha"]))
 def download(t):
  repo,commit,src,rel,size,blob=t
  data=get(f"https://raw.githubusercontent.com/{repo}/{commit}/{src}",token)
  if len(data)!=size: raise RuntimeError(f"Size mismatch: {rel}")
  info={}
  if rel.lower().endswith(".glb"): info=glb_info(data)
  elif rel.lower().endswith(".gltf"): json.loads(data.decode("utf-8"))
  dest=DEST/rel; dest.parent.mkdir(parents=True,exist_ok=True); dest.write_bytes(data)
  return {"path":rel,"source_repository":repo,"source_commit":commit,"source_path":src,"git_blob_sha":blob,"sha256":hashlib.sha256(data).hexdigest(),"size_bytes":len(data),"license":"CC0-1.0",**info}
 print(f"Downloading {len(tasks)} selected KayKit files")
 with concurrent.futures.ThreadPoolExecutor(max_workers=12) as pool:
  for i,rec in enumerate(pool.map(download,tasks),1):
   manifest["assets"].append(rec)
   if i%25==0 or i==len(tasks): print(f"[{i}/{len(tasks)}] {rec['path']}")
 missing=[]
 for rec in manifest["assets"]:
  if rec["path"].lower().endswith(".gltf"):
   p=DEST/rec["path"]; doc=json.loads(p.read_text(encoding="utf-8"))
   for section in ("buffers","images"):
    for obj in doc.get(section,[]):
     uri=obj.get("uri","")
     if uri and not uri.startswith("data:") and not (p.parent/uri).resolve().is_file(): missing.append(f"{rec['path']} -> {uri}")
 if missing: raise RuntimeError("Missing glTF references:\n"+"\n".join(missing[:40]))
 manifest["summary"]={"file_count":len(manifest["assets"]),"glb_count":sum(x["path"].lower().endswith(".glb") for x in manifest["assets"]),"gltf_count":sum(x["path"].lower().endswith(".gltf") for x in manifest["assets"]),"animated_glb_count":sum(bool(x.get("animations")) for x in manifest["assets"]),"total_bytes":sum(x["size_bytes"] for x in manifest["assets"])}
 DEST.mkdir(parents=True,exist_ok=True)
 (DEST/"ASSET_MANIFEST.json").write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
 print(json.dumps(manifest["summary"],indent=2))
if __name__=="__main__":
 try: raise SystemExit(main())
 except Exception as exc:
  print(f"KAYKIT IMPORT FAILED: {exc}",file=sys.stderr); raise

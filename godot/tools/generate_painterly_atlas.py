#!/usr/bin/env python3
"""Generate original deterministic brush-painted-style fantasy texture atlases."""
from __future__ import annotations
import json, math, random
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/"assets"/"materials"
SIZE=1024; GRID=4; TILE=SIZE//GRID; SEED=26061118
MATERIALS=[
 ("snow_stone",(105,126,145),(211,225,235),.88,.02),("dark_stone",(49,57,70),(129,143,157),.94,.03),
 ("warm_stone",(105,77,61),(194,158,124),.91,.02),("oak_wood",(81,48,30),(185,126,67),.82,0),
 ("iron",(53,66,79),(172,190,205),.36,.78),("gold",(105,67,22),(247,202,91),.29,.88),
 ("leather",(74,39,26),(173,103,59),.91,0),("blue_cloth",(29,48,79),(104,143,192),.96,0),
 ("red_cloth",(83,24,27),(188,77,65),.96,0),("green_cloth",(31,65,47),(114,158,91),.96,0),
 ("ice",(78,129,160),(205,239,249),.22,.12),("moss",(32,55,36),(122,142,72),.98,0),
 ("grass",(36,70,37),(139,161,76),.99,0),("bone",(106,91,70),(231,218,184),.87,0),
 ("fur",(47,43,43),(174,158,138),.99,0),("ember",(63,24,15),(255,154,54),.72,.02)]
def clamp(v): return max(0,min(255,int(v)))
def mix(a,b,t): return tuple(clamp(a[i]*(1-t)+b[i]*t) for i in range(3))
def paint(name,dark,light,rng):
 im=Image.new("RGB",(TILE,TILE)); px=im.load(); phase=rng.random()*math.tau
 for y in range(TILE):
  for x in range(TILE):
   d=(x*.55+y*.45)/(TILE-1); grain=rng.gauss(0,5); wave=math.sin(x*.035+y*.012+phase)*5
   base=mix(dark,light,max(0,min(1,.22+d*.62+wave/255)))
   px[x,y]=tuple(clamp(c+grain) for c in base)
 brush=Image.new("RGBA",(TILE,TILE),(0,0,0,0)); draw=ImageDraw.Draw(brush,"RGBA")
 for _ in range(520):
  x=rng.randrange(-12,TILE+12); y=rng.randrange(-12,TILE+12); length=rng.randrange(8,58); drift=rng.uniform(-.65,.65)
  pts=[(int(x+length*s/4),int(y+drift*length*s/4+math.sin(s*1.4+phase)*rng.uniform(0,3))) for s in range(5)]
  color=mix(dark,light,rng.uniform(.18,.94))
  if rng.random()<.35: color=mix(color,(12,14,18),.22)
  draw.line(pts,fill=(*color,rng.randint(16,68)),width=rng.choice((1,1,2,2,3,4)),joint="curve")
  if rng.random()<.22:
   r=rng.uniform(1,3.2); draw.ellipse((x-r,y-r,x+r,y+r),fill=(*color,rng.randint(18,75)))
 im=Image.alpha_composite(im.convert("RGBA"),brush).convert("RGB")
 flecks=Image.new("RGBA",(TILE,TILE),(0,0,0,0)); fd=ImageDraw.Draw(flecks,"RGBA")
 for _ in range(260):
  x,y=rng.randrange(TILE),rng.randrange(TILE); c=light if rng.random()>.35 else dark; r=rng.choice((1,1,2))
  fd.ellipse((x-r,y-r,x+r,y+r),fill=(*c,rng.randint(18,70)))
 return Image.alpha_composite(im.convert("RGBA"),flecks).convert("RGB").filter(ImageFilter.GaussianBlur(.28))
def main():
 OUT.mkdir(parents=True,exist_ok=True); rng=random.Random(SEED)
 albedo=Image.new("RGB",(SIZE,SIZE)); rough=Image.new("L",(SIZE,SIZE),220); metal=Image.new("L",(SIZE,SIZE),0)
 for i,(name,dark,light,r,m) in enumerate(MATERIALS):
  x=(i%GRID)*TILE; y=(i//GRID)*TILE; albedo.paste(paint(name,dark,light,rng),(x,y))
  rt=Image.new("L",(TILE,TILE),clamp(r*255)); rd=ImageDraw.Draw(rt)
  for _ in range(180):
   px,py=rng.randrange(TILE),rng.randrange(TILE); v=clamp(r*255+rng.randint(-22,22)); rad=rng.choice((1,2,3))
   rd.ellipse((px-rad,py-rad,px+rad,py+rad),fill=v)
  rough.paste(rt,(x,y)); metal.paste(Image.new("L",(TILE,TILE),clamp(m*255)),(x,y))
 albedo.save(OUT/"painterly_fantasy_albedo.png",optimize=True)
 rough.save(OUT/"painterly_fantasy_roughness.png",optimize=True)
 metal.save(OUT/"painterly_fantasy_metallic.png",optimize=True)
 manifest={"name":"Original Painterly Fantasy Material Atlas","seed":SEED,"resolution":[SIZE,SIZE],"grid":[GRID,GRID],"tile_size":[TILE,TILE],"license":"Original project-generated textures","maps":{"albedo":"painterly_fantasy_albedo.png","roughness":"painterly_fantasy_roughness.png","metallic":"painterly_fantasy_metallic.png"},"tiles":[{"index":i,"name":m[0],"uv_origin":[(i%GRID)/GRID,(i//GRID)/GRID],"uv_size":[1/GRID,1/GRID],"roughness":m[3],"metallic":m[4]} for i,m in enumerate(MATERIALS)],"note":"Procedural brush-painted style; not extracted from WoW or third-party games."}
 (OUT/"painterly_fantasy_atlas.json").write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
 print(f"Generated 3 1024x1024 maps with {len(MATERIALS)} material tiles.")
if __name__=="__main__": main()

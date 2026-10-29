#!/usr/bin/env bash
# 10-27 website media encodes (all 1280x720 or native, never upscaled; crf 22-24, faststart). Pans: box/cloth/marker from pan2, rope/pusht/plug from pan3 when rendered.
B=/home/jimmy/robopil/jimmy/rollout_view_1019; cd $B; export PATH=/home/jimmy/robopil/jimmy/miniconda3/envs/pointworld-data/bin:$PATH; S=relight/web/site; H=relight/web/hero
X="-c:v libx264 -preset slow -pix_fmt yuv420p -movflags +faststart -an"
enc(){ [ -f "$2" ] && return; ffmpeg -y -v error -i "$1" "${@:3}" $X "$2" && echo "[media] $2 $(du -h "$2" | cut -f1)"; }
enc $H/out/teaser_full_v5.mp4 $S/media/teaser.mp4 -crf 22
enc $H/out/chain_v15.mp4 $S/media/backgrounds.mp4 -ss 8.0 -vf scale=1280:720 -crf 22
enc $H/out/policy_training_v2.mp4 $S/media/training.mp4 -crf 22
enc $H/pe_src/media/deform360.mp4 $S/media/deform360.mp4 -crf 23
enc $H/pe_src/dl/teaser_grid_ghost.mp4 $S/media/planning.mp4 -vf "setpts=0.5*PTS,scale=1280:720" -r 30 -crf 22
for k in pe_plug_a_cam1 pe_plug_b_cam1 pe_plug_a_wrist3 pe_plug_b_wrist3 pe_cloth_ok_cam1 pe_cloth_fail_cam1; do enc $H/pe_src/media/$k.mp4 $S/media/$k.mp4 -crf 23; done
E=tmp/policy_eval_1023/out/cloth_wrist_teaser_Erollpe
enc $E/cloth_3020_wrist3.mp4 $S/media/pe_cloth_ok_wrist3.mp4 -vf "crop=1280:648:0:72" -crf 23; enc $E/cloth_3005_wrist3.mp4 $S/media/pe_cloth_fail_wrist3.mp4 -vf "crop=1280:648:0:72" -crf 23
enc $E/cloth_3020_wrist4.mp4 $S/media/pe_cloth_ok_wrist4.mp4 -vf "crop=1280:648:0:72" -crf 23; enc $E/cloth_3005_wrist4.mp4 $S/media/pe_cloth_fail_wrist4.mp4 -vf "crop=1280:648:0:72" -crf 23
for t in box cloth marker; do mkdir -p $S/pan/$t; for m in splats points latents voxels raw; do enc relight/web/pan2/$t/$m.mp4 $S/pan/$t/$m.mp4 -crf 24; done; done
for t in rope_wrist pusht plug; do [ -f relight/web/pan3/$t/raw.mp4 ] || continue; mkdir -p $S/pan/$t; for m in splats points latents voxels raw; do enc relight/web/pan3/$t/$m.mp4 $S/pan/$t/$m.mp4 -crf 24; done; done
for t in box cloth marker rope_wrist pusht plug; do [ -f $S/pan/$t/splats.mp4 ] && [ ! -f $S/pan/$t/poster.jpg ] && ffmpeg -y -v error -ss 0.5 -i $S/pan/$t/splats.mp4 -frames:v 1 -vf scale=640:-2 -q:v 4 $S/pan/$t/poster.jpg; done
for k in teaser backgrounds training deform360 planning; do [ -f $S/media/$k.jpg ] || ffmpeg -y -v error -ss 0.2 -i $S/media/$k.mp4 -frames:v 1 -vf scale=1280:-2 -q:v 4 $S/media/$k.jpg; done
[ -f tmp/policy_eval_1023/out/pv_site/pusht_ok_plain_cam0.mp4 ] && for v in ok fail; do for var in outline plain; do enc tmp/policy_eval_1023/out/pv_site/pusht_${v}_${var}_cam0.mp4 $S/media/pe_pusht_${v}_${var}.mp4 -crf 23; done; done
echo "[media] DONE"; du -sh $S/media $S/pan
# plug wrists (extrinsics head, FINAL_1023) and cloth static cams (pv_sharp) were encoded by hand on 10-27; manifest of the rendered pans:
python3 - <<'PY'
import os, json; S="relight/web/site"; M={}
for t in ["cloth","box","plug","pusht","marker","rope_wrist"]:
    ms=[m for m in ["splats","points","latents","voxels","raw"] if os.path.exists(f"{S}/pan/{t}/{m}.mp4")]
    if ms: M[t]=ms
open(f"{S}/pan/manifest.js","w").write("window.PAN = "+json.dumps(M)+";\n"); print("[media] manifest", M)
PY

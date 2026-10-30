# 3D World Simulator website

Static site: `index.html` + `media/` + `pan/`. No build step. Everything is plain HTML, CSS and JavaScript; the only external resource is the Inter font from Google Fonts.

## Local preview

    cd relight/web/site && python3 -m http.server 8150

## Media v5 (30 Oct)

`../site_media_v5.sh pans|mv|manifest`: box, cloth, marker and rope use the side orbit that starts on the left (`../pan4`), Push-T and plug the teaser-sweep camera (`../pan5`), gains as v4. New picker mode "Three views" = `pan/<task>/multiview.mp4`: dataset camera 0 (overhead), dataset camera 2 (far side of the table) and the task's pan side by side, frame-aligned (`../multiview_fixed.py` through `showcase_videos.sh` -> `../mvfixed/<task>/cam{0,2}.mp4`, composited by the `mv` step). The stage widens to the video's aspect for that mode.

## Media v3 (29 Oct)

`../site_media_v3.sh` is the current build: teaser v16, `backgrounds.mp4` from `chain_v17` (brightness-only scan colour + per-task exposure gains), the
T1 training layout, policy-evaluation clips with the same gains as the teaser (plug x2.35 static / x1.47 wrist, Push-T x1.61 without the IoU numbers (success = the teaser's episode 901000, pv_901.sh),
cloth wrists x1.06), and `pan/<task>/` from `../pan4` (all six tasks rendered with `SCAN_COLOR_MODE=lum`, then a per-task gain that brings the table
white to the cloth film's level; `bash ../site_media_v3.sh pans`, gains in `../pan4/gains.json`; latents/voxels views are not gained). The page
(`index.html`, previous version `index.html.bak_1029`) numbers the sections, lists them under the teaser and in a side rail on wide screens.

## Regenerating media (v1/v2, kept for reference)

`build_media.sh` re-encodes every clip from the sources under `relight/web/hero/out`, `relight/web/pan2` / `pan3`, `tmp/policy_eval_1023/out` and `FINAL_1023`, skipping files that already exist, and writes `pan/manifest.js` (which task has which views). Delete a file in `media/` or `pan/` to force a re-encode.

- `media/teaser.mp4`: the full teaser (`teaser_cut.py`, 1280 x 720, 50 fps).
- `media/backgrounds.mp4`: the chained cut from the lab pull-back on (rooms, SO-101 arms, grid).
- `media/training.mp4`: the 20x / 80x real-robot clip with speed badges (`train_cut.py`).
- `media/deform360.mp4`, `media/planning.mp4` (ghost grid at 2x).
- `media/pe_*.mp4`: policy-evaluation clips. Push-T is rendered without burnt-in text (`tmp/policy_eval_1023/pv_site.sh`, `_outline` keeps the goal outline, `_plain` has none).
- `pan/<task>/<mode>.mp4`: rollout views (splats, points, latents, voxels, raw). Box, cloth and marker from `pan2`; rope, Push-T and plug from `pan3` (padeye kept, distilled joint heads).

## Editing from anywhere (git)

This directory is a git repository (`main`, 66 files, 273 MB; `review/` and `*.bak*` are ignored). The workflow is: edit anywhere, push, GitHub Pages republishes within a minute.

    git clone git@github.com:3dworldsimulator/3dworldsimulator.github.io.git   # laptop, another workstation, Claude Code web
    # edit index.html (or drop new clips into media/ and pan/)
    python3 -m http.server 8150                                                 # preview at http://localhost:8150
    git commit -am "..." && git push

The corsair copy (`relight/web/site`) is the clone that the `site-http` preview unit serves on :8150; pull there before regenerating media.
Only the encoded clips live in the repo; the renders and encoders (`../site_media_v3.sh`, `../pan4_task.sh`, `../../3dws_teaser`) stay on corsair,
so a new clip is: render on corsair -> encode into `media/` or `pan/` -> commit -> push. Keep single files under 100 MB and the repository under 1 GB.

## Publishing on GitHub Pages

1. Create the organization `3dworldsimulator` on GitHub and a repository named `3dworldsimulator.github.io` (public).
2. In this directory:

        git init && git add -A && git commit -m "site"
        git branch -M main
        git remote add origin git@github.com:3dworldsimulator/3dworldsimulator.github.io.git
        git push -u origin main

3. On GitHub: Settings > Pages > Source: "Deploy from a branch", branch `main`, folder `/ (root)`. The site is live at https://3dworldsimulator.github.io a minute later.

Limits: single files must stay under 100 MB (the largest here are the particle views, about 30 MB) and the repository is best kept under 1 GB. The `.nojekyll` file stops GitHub from processing the folder with Jekyll.

## Interactive demo

The demo panel loads https://jwang771--3dws-demo.us-east.modal.run in an iframe only after the visitor presses "Start the demo", so no GPU container is started by just opening the page. Each session starts one GPU container on Modal (cold start about 45 s). To change the URL, edit the `demoStart` handler in `index.html`.

#!/bin/bash
# CÓPIA — o principal é claude/au-vidanim.sh do projeto AURUM EDITS.
# vid.sh in theme fps out X Y S OW OH   (S=132 padrão 1080x1920; 92 em feed)
in="$1"; th="$2"; fps="$3"; out="$4"; X=${5:-474}; Y=${6:-1560}; S=${7:-132}; OW=${8:-1080}; OH=${9:-1920}
P=$(python3 -c "print(round(40*$S/132))"); C=$((S+2*P))
D=/home/claude/au2/seq_${th}_${fps//\//_}_$S
F=$(python3 -c "print(eval('$fps'))")
[ -d "$D" ] || node /home/claude/au2/anim.js $th $F $D $S
ffmpeg -v error -y -i "$in" \
 -framerate $fps -i $D/intro_%04d.png -stream_loop -1 -framerate $fps -i $D/cyc_%04d.png \
 -framerate $fps -i $D/mintro_%04d.png -stream_loop -1 -framerate $fps -i $D/mcyc_%04d.png \
 -filter_complex "
[1:v][2:v]concat=n=2:v=1,format=rgba,setpts=PTS-STARTPTS[ov];
[3:v][4:v]concat=n=2:v=1,format=gray,setpts=PTS-STARTPTS[mk];
[0:v]scale=$OW:$OH:flags=lanczos,setsar=1,fps=$fps,split[base][g];
[g]crop=$C:$C:$((X-P)):$((Y-P)),gblur=sigma=14,eq=saturation=1.2,format=rgba[bl];
[bl][mk]alphamerge[glass];
[base][glass]overlay=$((X-P)):$((Y-P)):shortest=1[b2];[b2][ov]overlay=$((X-P)):$((Y-P)):shortest=1,format=yuv420p[v]" \
 -map "[v]" -map 0:a? -c:v libx264 -preset veryfast -crf 17 -profile:v high -c:a aac -b:a 192k -movflags +faststart "$out"

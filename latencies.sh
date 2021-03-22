#!/bin/bash

CODE=''

SV="$IFS"
IFS=$'\n'
for i in $(grep -rl 'latency: [0-9]');do
	CODE="${CODE} $(sed -n 's,\([a-z]\) \([a-z]\),\1_\2,g ; s,_latency: \([0-9]\+\).*,.append(\1),p' < "$i")"
done

IFS="$SV"
FINAL=$(for i in $CODE;do
	echo $i
done)

python<<EOF
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

bins=40

Audio=[]
Video=[]
Interlaced_audio=[]
Interlaced_video=[]
$FINAL

audio = pd.Series(Audio)
video = pd.Series(Video)
ivideo = pd.Series(Interlaced_video)
iaudio = pd.Series(Interlaced_audio)

fig, axs = plt.subplots(4)

audio.plot.hist(grid=True, bins=bins, color='#607c8e', ax=axs[0])
axs[0].set(xlabel='latency (ms)', ylabel='audio')
video.plot.hist(grid=True, bins=bins, color='#607c8e', ax=axs[1])
axs[1].set(xlabel='latency (ms)', ylabel='video')
iaudio.plot.hist(grid=True, bins=bins, color='#607c8e', ax=axs[2])
axs[2].set(xlabel='latency (ms)', ylabel='iaudio')
ivideo.plot.hist(grid=True, bins=bins, color='#607c8e', ax=axs[3])
axs[3].set(xlabel='latency (ms)', ylabel='ivideo')
plt.show()
EOF

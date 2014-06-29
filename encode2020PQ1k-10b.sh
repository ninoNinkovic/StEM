set -x


x265 --input 2020PQ1k-10b.yuv --input-depth 10 --input-res 1920x1080 --fps 23.976 --crf 23 --vbv-maxrate 20000 --vbv-bufsize 70000  -p medium --bframes 12 -I 72 --psnr --sar 1 --range limited --colorprim bt2020 --transfer bt2020-10 --colormatrix bt2020nc --chromaloc 1 --no-lft --repeat-headers -o 2020PQ1k-10b.bin 2>&1 | tee log-2020PQ1k-10b.txt



mpv --loop 5 --osd-level=0 --colormatrix-input-range=limited --colormatrix-output-range=full 2020PQ1k-10b.bin


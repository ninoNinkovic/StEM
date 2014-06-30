set -x


$EDRHOME/HEVC/x265/build/linux/x265-8bit --input 709VR-10b.yuv --input-depth 10 --input-res 1920x1080 --fps 23.976 --crf 22 --vbv-maxrate 20000 --vbv-bufsize 70000  -p medium --bframes 12 -I 72 --psnr --sar 1 --range limited --colorprim bt709 --transfer bt709 --colormatrix bt709 --chromaloc 1 --no-lft  --repeat-headers -o 709VR-8b.bin 2>&1 | tee log-709VR-8b.txt



#mpv --loop 5 --osd-level=0 --colormatrix-input-range=limited --colormatrix-output-range=full 709VR-8b.bin


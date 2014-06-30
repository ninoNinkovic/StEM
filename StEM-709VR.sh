set -x



mkdir StEM-709VR
rm -fv StEM-709VR/*


# find all exr files
c1=0
CMax=3
num=0
rm -fv YDzDx.yuv

for filename in PQ/StEM*XYZ/000[0-1][0-1][0-9].tif ; do

 # file name w/extension e.g. 000111.tiff
 cFile="${filename##*/}"
 # remove extension
 cFile="${cFile%.tif}"
 # note cFile now does NOT have tiff extension!
 #echo -e "crop: $filename \n"
 
 
 numStr=`printf "%06d" $num`
 num=`expr $num + 1`
 
if [ $c1 -le $CMax ]; then



(ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ10k-2-XYZ.ctl -ctl $EDRHOME/ACES/CTL/XYZ2ACES.ctl\
     -ctl $EDRHOME/ACES/CTL/odt_rec709_smpte_NOTC.ctl -param1 MAX 200.0 $filename  -format tiff16 "StEM-709VR/XpYpZp"$numStr".tiff" ) &


c1=$[$c1 +1]
fi

if [ $c1 = $CMax ]; then
for job in `jobs -p`
do
echo $job
wait $job 
done
c1=0
fi

done

for filename in StEM-709VR/Xp*tiff ; do

  $EDRHOME/Tools/YUV/tif2yuv $filename B10 709 HD1920
  
  
done

mv YDzDx.yuv 709VR-10b.yuv
ls -l *yuv

exit



#(ctlrender -verbose -force -ctl $EDRHOME/ACES/CTL/S-gamut_to_ACES.ctl -ctl $EDRHOME/ACES/aces-dev-dev/transforms/ctl/rrt/rrt.ctl ./tifRGB/$cFile".tif" -format exr32 TMP$c1".exr" ; ctlrender -verbose -force  -ctl $EDRHOME/ACES/CTL/odt_PQ10k.ctl TMP$c1".exr" -format tiff16 FSPQ/$cFile".tif" ; ctlrender -verbose -force  -ctl $EDRHOME/ACES/CTL/odt_rec709_full_100nits.ctl TMP$c1".exr" -format tiff16 FS709/$cFile".tif") &

#mpv --loop 2 --osd-level=0 --demuxer=rawvideo --demuxer-rawvideo=w=1920:h=1080:fps=23.976:mp-format=yuv420p10le --colormatrix-input-range=limited --colormatrix-output-range=full YDzDx.yuv

#mpv --loop 1000 --osd-level=0 --demuxer=rawvideo --demuxer-rawvideo=w=1920:h=1080:fps=23.976:mp-format=yuv420p10le --colormatrix BT.709 --colormatrix-input-range=limited --colormatrix-output-range=full YDzDx.yuv



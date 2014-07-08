set -x



#mkdir StEM-2020PQ1k
#rm -fv StEM-2020PQ1k/*


# find all exr files
c1=0
CMax=3
num=0
rm -fv YDzDx.yuv

for filename in PQ/StEM*XYZ/000[1][1][9].tif ; do

 # file name w/extension e.g. 000111.tiff
 cFile="${filename##*/}"
 # remove extension
 cFile="${cFile%.tif}"
 # note cFile now does NOT have tiff extension!
 #echo -e "crop: $filename \n"
 
 
 numStr=`printf "%06d" $num`
 num=`expr $num + 1`
 
if [ $c1 -le $CMax ]; then



#(ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ10k-2-XYZ.ctl -ctl $EDRHOME/ACES/CTL/XYZ2ACES.ctl\
#    -ctl $EDRHOME/ACES/CTL/odt_PQ1k2020.ctl $filename  -format tiff16 #"StEM-2020PQ1k/XpYpZp"$numStr".tiff" ) &


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

# make sure all jobs finished
for job in `jobs -p`
do
echo $job
wait $job 
done



for filename in StEM-2020PQ1k/Xp*tiff ; do
  # 2020C and G1k go together as gamma is needed to 
  # be known for Constant Luminance processing. 
  $EDRHOME/Tools/YUV/tif2yuv $filename B10 2020C G1k HD1920
  
  
done

mv YDzDx.yuv 2020CL-PQ1k-10b.yuv
ls -l *yuv


# Basic verification of yuv processing step
# will skip when doing full run with 
# next scripts that perform encoding and final sigma_compare
rm -rfv logCL
mkdir logCL
mkdir tifXYZ
rm -rfv 2020CL-PQ1k-10b-YUVRT
$EDRHOME/Tools/YUV/yuv2tif 2020CL-PQ1k-10b.yuv B10 2020C G1k HD1920 -f 5 -I
mv tifXYZ 2020CL-PQ1k-10b-YUVRT

# sigma compare input to output
for filename in 2020CL-PQ1k-10b-YUVRT/Xp*tif ; do

 # file name w/extension e.g. 000111.tiff
 cFile="${filename##*/}"
 # remove extension
 cFile="${cFile%.tif}"
 # note cFile now does NOT have tiff extension!

	# write EXR file from YUV
	ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ1k2020-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   $filename -format exr16 tmpRTYUVasXYZ.exr
	ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ1k2020-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/XYZ-2-2020.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   $filename -format exr16 tmpRTYUV.exr	   
	# write EXR file from PQ 444 Input to YUV   
	ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ1k2020-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   StEM-2020PQ1k/$cFile".tiff" -format exr16 tmp444asXYZ.exr	   
	ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ1k2020-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/XYZ-2-2020.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   StEM-2020PQ1k/$cFile".tiff" -format exr16 tmp444.exr	 	   
	# sigma compare 444 to YUV as XYZ and as RGB 2020
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp444asXYZ.exr tmpRTYUVasXYZ.exr\
	    2>&1 > logCL/$cFile"-444-RTYUV-asXYZ.txt"  
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp444.exr tmpRTYUV.exr\
	    2>&1 > logCL/$cFile"-444-RTYUV-as2020RGB.txt" 
  
done

exit



#(ctlrender -verbose -force -ctl $EDRHOME/ACES/CTL/S-gamut_to_ACES.ctl -ctl $EDRHOME/ACES/aces-dev-dev/transforms/ctl/rrt/rrt.ctl ./tifRGB/$cFile".tif" -format exr32 TMP$c1".exr" ; ctlrender -verbose -force  -ctl $EDRHOME/ACES/CTL/odt_PQ10k.ctl TMP$c1".exr" -format tiff16 FSPQ/$cFile".tif" ; ctlrender -verbose -force  -ctl $EDRHOME/ACES/CTL/odt_rec709_full_100nits.ctl TMP$c1".exr" -format tiff16 FS709/$cFile".tif") &


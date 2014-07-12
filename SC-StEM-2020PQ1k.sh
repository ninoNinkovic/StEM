
# last script
# sequence to run typically is
# StEM-2020PQ1k.sh, StEM-2020CL-PQ1k.sh, encode2020PQ1k-10b.sh
# StEM-709VR.sh, encode709VR-8b.sh
# then this script to compare everything.
# generally can comment out a lot and just run what needs to be recreated.
#

set -x

ls StEM-2020PQ1k

# in case want to clean up log files
#mkdir log
#rm -fv log/*
#mkdir logCL
#rm -fv logCL/*

#dump yuv back to tiff
num=0
mkdir tifXYZ
rm -rfv StEM-2020PQ1k-RTYUV
$EDRHOME/Tools/YUV/yuv2tif 2020-PQ1k-10b.yuv B10 2020 HD1920 -f 150
mv tifXYZ StEM-2020PQ1k-RTYUV

#dump 2020CL back to tiff
mkdir tifXYZ
rm -rfv StEM-2020CLPQ1k-RTYUV
$EDRHOME/Tools/YUV/yuv2tif 2020CL-PQ1k-10b.yuv B10 2020CL G1k HD1920 -f 150
mv tifXYZ StEM-2020CLPQ1k-RTYUV


#decode HEVC to yuv
$EDRHOME/FF/ffmpeg/ffmpeg -y -r 23.976 -f hevc -i 2020PQ1k-10b.bin  -an \
   -pix_fmt yuv420p10le -f rawvideo -vcodec rawvideo 2020PQ1k-10b-decode.yuv
   
# for 2020CL
$EDRHOME/FF/ffmpeg/ffmpeg -y -r 23.976 -f hevc -i 2020CL-PQ1k-10b.bin  -an \
   -pix_fmt yuv420p10le -f rawvideo -vcodec rawvideo 2020CLPQ1k-10b-decode.yuv

# convert decoded PQ1k HEVC to 2020PQ1k 
num=0
mkdir tifXYZ
rm -rfv StEM-2020PQ1k-PQ1kHEVC
$EDRHOME/Tools/YUV/yuv2tif 2020PQ1k-10b-decode.yuv B10 2020 HD1920 -f 150
mv tifXYZ StEM-2020PQ1k-PQ1kHEVC

# for 2020CL
mkdir tifXYZ
rm -rfv StEM-2020CLPQ1k-PQ1kHEVC
$EDRHOME/Tools/YUV/yuv2tif 2020CLPQ1k-10b-decode.yuv B10 2020C G1k HD1920 -f 150
mv tifXYZ StEM-2020CLPQ1k-PQ1kHEVC

#decode 709 HEVC to yuv
$EDRHOME/FF/ffmpeg/ffmpeg -y -r 23.976 -i 709VR-8b.bin -an \
   -pix_fmt yuv420p10le -f rawvideo -vcodec rawvideo 709VR-8b-2-10b-decode.yuv

# convert decoded 709 to tiff
mkdir tifXYZ
rm -rfv StEM-709VR-8b-HEVC
$EDRHOME/Tools/YUV/yuv2tif 709VR-8b-2-10b-decode.yuv B10 709 HD1920 -f 150
mv tifXYZ StEM-709VR-8b-HEVC
   
   
# show decoded file sizes
ls -lt *yuv
sleep 3
num=0

for filename in PQ/StEM*XYZ/000[1][0-2][0-9].tif ; do
#for filename in PQ/StEM*XYZ/000[0-1][0-1][0-9].tif ; do
#for filename in StEM-2020PQ1k-RTYUV/* ; do

     numMod=$(($num % 30))
	 if [ "$numMod" -ne 0 ]
	 then
	   num=$(($num + 1))
	   continue  # Skip entire rest of loop.
	 fi	


    numStr=`printf "%06d" $num`
    num=`expr $num + 1`
    
    
    # write EXR from source
    ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ10k-2-XYZ.ctl -ctl \
        $EDRHOME/ACES/CTL/nullA.ctl $filename -format exr16 tmp.exr
	# self compare source to source
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp.exr tmp.exr \
	    2>&1 > log/self$numStr"-SRC.txt"
        
	# write EXR file from YUV
	ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ1k2020-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   StEM-2020PQ1k-RTYUV/XpYpZp$numStr".tif" -format exr16 tmpRTYUV.exr
	# self compare YUV to YUV
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpRTYUV.exr tmpRTYUV.exr\
	    2>&1 > log/self$numStr"-RTYUV.txt"
	    
	# for 2020CL
	ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ1k2020-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   StEM-2020CLPQ1k-RTYUV/XpYpZp$numStr".tif" -format exr16 tmpRTYUVCL.exr
	# self compare YUV to YUV
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpRTYUVCL.exr tmpRTYUVCL.exr\
	    2>&1 > log/self$numStr"-RTYUVCL.txt"
	    
	    	
	# write EXR file from 444
	ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ1k2020-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   "StEM-2020PQ1k/XpYpZp"$numStr".tiff" -format exr16 tmp444.exr
	# self compare 444 to 444
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp444.exr tmp444.exr \
	    2>&1 > log/self$numStr"-444.txt"
	    
	# write EXR file from HEVC
	ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ1k2020-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   StEM-2020PQ1k-PQ1kHEVC/XpYpZp$numStr".tif" -format exr16 tmpHEVC.exr
	# self compare HEVC to HEVC
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpHEVC.exr tmpHEVC.exr\
	    2>&1 > log/self$numStr"-HEVC.txt"
	# compare HEVC to yuv
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpRTYUV.exr tmpHEVC.exr\
	    2>&1 > log/self$numStr"-YUV2HEVC.txt"	
	    
	# for 2020CL    
	ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQ1k2020-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   StEM-2020CLPQ1k-PQ1kHEVC/XpYpZp$numStr".tif" -format exr16 tmpHEVC-CL.exr
	# self compare HEVC to HEVC
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpHEVC-CL.exr tmpHEVC-CL.exr\
	    2>&1 > log/self$numStr"-HEVC-CL.txt"
	# compare HEVC to yuv
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpRTYUVCL.exr tmpHEVC-CL.exr\
	    2>&1 > log/self$numStr"-YUV2HEVC-CL.txt"		    
	    
	# compare 709VR 444 to self
	ctlrender -force -ctl $EDRHOME/ACES/CTL/odt_rec709_smpte_inv_NOTC.ctl -param1 MAX 200.0 \
	   -ctl $EDRHOME/ACES/CTL/ACES-2-XYZ.ctl -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   "StEM-709VR/XpYpZp"$numStr".tiff" -format exr16 tmp709VR-444-XYZOCES.exr
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp709VR-444-XYZOCES.exr tmp709VR-444-XYZOCES.exr \
	    2>&1 > log/self$numStr"-709VR444-XYZOCES.txt"		

	# convert 709VR HEVC to OCES linear
	ctlrender -force -ctl $EDRHOME/ACES/CTL/odt_rec709_smpte_inv_NOTC.ctl -param1 MAX 200.0 \
	   -ctl $EDRHOME/ACES/CTL/ACES-2-XYZ.ctl -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   StEM-709VR-8b-HEVC/XpYpZp$numStr".tif" -format exr16 tmp709VR-HEVC-XYZOCES.exr	
  
	# compare 709VR to decoded HEVC as XYZ OCES
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp709VR-HEVC-XYZOCES.exr tmp709VR-HEVC-XYZOCES.exr \
	    2>&1 > log/selfHEVC$numStr"-709VRHEVC-XYZOCES.txt"		    	   
	   
	# compare 709VR to 2020PQ1k decoded HEVC to 709 as OCES
	ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQnk2020-2-OCES.ctl -param1 1000.0 \
	   -ctl $EDRHOME/ACES/CTL/odt_rec709_smpte_NOTC.ctl -param1 MAX 200.0 \
	   -ctl $EDRHOME/ACES/CTL/odt_rec709_smpte_inv_NOTC.ctl -param1 MAX 200.0 \
	   -ctl $EDRHOME/ACES/CTL/ACES-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   StEM-2020PQ1k-PQ1kHEVC/XpYpZp$numStr".tif" -format exr16 tmpHEVCas709.exr	
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpHEVCas709.exr tmp709VR-HEVC-XYZOCES.exr \
	    2>&1 > log/HEVC$numStr"-2020PQ1kHEVC-709VRHEVC-XYZOCES.txt"	
	# for 2020CL
	ctlrender -force -ctl $EDRHOME/ACES/CTL/INVPQnk2020-2-OCES.ctl -param1 1000.0 \
	   -ctl $EDRHOME/ACES/CTL/odt_rec709_smpte_NOTC.ctl -param1 MAX 200.0 \
	   -ctl $EDRHOME/ACES/CTL/odt_rec709_smpte_inv_NOTC.ctl -param1 MAX 200.0 \
	   -ctl $EDRHOME/ACES/CTL/ACES-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   StEM-2020CLPQ1k-PQ1kHEVC/XpYpZp$numStr".tif"  -format exr16 tmpHEVC-CLas709.exr	
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpHEVC-CLas709.exr tmp709VR-HEVC-XYZOCES.exr \
	    2>&1 > log/HEVC$numStr"-2020CLPQ1kHEVC-709VRHEVC-XYZOCES.txt"		
	    
	# compare SRC to 444
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp.exr tmp444.exr \
	    2>&1 > log/$numStr"-SRC-444.txt"
	    	    
	# compare 444 to YUV
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp444.exr tmpRTYUV.exr \
	    2>&1 > log/$numStr"-444-YUV.txt"
	#2020 CL
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp444.exr tmpRTYUVCL.exr \
	    2>&1 > log/$numStr"-444-YUV-CL.txt"
	    	
	    	
	    	
done


exit


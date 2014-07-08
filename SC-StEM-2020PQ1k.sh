set -x



#ls StEM-2020PQ1k
#mkdir log
rm -fv log/*

#dump yuv back to tiff
num=0
#mkdir tifXYZ
#rm -rfv StEM-2020PQ1k-RTYUV
#$EDRHOME/Tools/YUV/yuv2tif 2020PQ1k-10b.yuv B10 2020 HD1920 -f 200
#mv tifXYZ StEM-2020PQ1k-RTYUV


#decode HEVC to yuv
#$EDRHOME/FF/ffmpeg/ffmpeg -y -r 23.976 -f hevc -i 2020PQ1k-10b.bin  -an \
#   -pix_fmt yuv420p10le -f rawvideo -vcodec rawvideo 2020PQ1k-10b-decode.yuv

# convert decoded PQ1k HEVC to 2020PQ1k 
num=0
#mkdir tifXYZ
#rm -rfv StEM-2020PQ1k-PQ1kHEVC
#$EDRHOME/Tools/YUV/yuv2tif 2020PQ1k-10b-decode.yuv B10 2020 HD1920 -f 200
#mv tifXYZ StEM-2020PQ1k-PQ1kHEVC

#decode 709 HEVC to yuv
#$EDRHOME/FF/ffmpeg/ffmpeg -y -r 23.976 -i 709VR-8b.bin -an \
#   -pix_fmt yuv420p10le -f rawvideo -vcodec rawvideo 709VR-8b-2-10b-decode.yuv

# convert decoded 709 to tiff
#mkdir tifXYZ
#rm -rfv StEM-709VR-8b-HEVC
#$EDRHOME/Tools/YUV/yuv2tif 709VR-8b-2-10b-decode.yuv B10 709 HD1920 -f 198
#mv tifXYZ StEM-709VR-8b-HEVC
   
   
# show decoded file sizes
ls -lt *yuv
sleep 3

for filename in PQ/StEM*XYZ/000[0-1][0-1][0-9].tif ; do
#for filename in StEM-2020PQ1k-RTYUV/* ; do

    numStr=`printf "%06d" $num`
    numStr5=`printf "%05d" $num`
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
	   StEM-2020PQ1k-RTYUV/XpYpZp$numStr5".tif" -format exr16 tmpRTYUV.exr
	# self compare YUV to YUV
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpRTYUV.exr tmpRTYUV.exr\
	    2>&1 > log/self$numStr"-RTYUV.txt"
	
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
	   StEM-2020PQ1k-PQ1kHEVC/XpYpZp$numStr5".tif" -format exr16 tmpHEVC.exr
	# self compare HEVC to HEVC
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpHEVC.exr tmpHEVC.exr\
	    2>&1 > log/self$numStr"-HEVC.txt"
	# compare HEVC to yuv
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpRTYUV.exr tmpHEVC.exr\
	    2>&1 > log/self$numStr"-YUV2HEVC.txt"		    
	    
	# compare 709VR 444 to self
	ctlrender -force -ctl $EDRHOME/ACES/CTL/odt_rec709_smpte_inv_NOTC.ctl -param1 MAX 200.0 \
	   -ctl $EDRHOME/ACES/CTL/ACES-2-XYZ.ctl -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   "StEM-709VR/XpYpZp"$numStr".tiff" -format exr16 tmp709VR-444-XYZOCES.exr
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp709VR-444-XYZOCES.exr tmp709VR-444-XYZOCES.exr \
	    2>&1 > log/self$numStr"-709VR444-XYZOCES.txt"		

	# convert 709VR HEVC to OCES linear
	ctlrender -force -ctl $EDRHOME/ACES/CTL/odt_rec709_smpte_inv_NOTC.ctl -param1 MAX 200.0 \
	   -ctl $EDRHOME/ACES/CTL/ACES-2-XYZ.ctl -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   StEM-709VR-8b-HEVC/XpYpZp$numStr5".tif" -format exr16 tmp709VR-HEVC-XYZOCES.exr	
  
	# compare 709VR to decoded HEVC as XYZ OCES
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp709VR-HEVC-XYZOCES.exr tmp709VR-HEVC-XYZOCES.exr \
	    2>&1 > log/selfHEVC$numStr"-709VRHEVC-XYZOCES.txt"		    	   
	   
	# compare 709VR to 2020PQ1k decoded HEVC to 709 as OCES
	ctlrender -force -ctl $EDRHOME/ACES/CTL/XYZ2ACES.ctl \
	   -ctl $EDRHOME/ACES/CTL/odt_rec709_smpte_NOTC.ctl -param1 MAX 200.0 \
	   -ctl $EDRHOME/ACES/CTL/odt_rec709_smpte_inv_NOTC.ctl -param1 MAX 200.0 \
	   -ctl $EDRHOME/ACES/CTL/ACES-2-XYZ.ctl \
	   -ctl $EDRHOME/ACES/CTL/nullA.ctl \
	   tmpHEVC.exr -format exr16 tmpHEVCas709.exr	
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmpHEVCas709.exr tmp709VR-HEVC-XYZOCES.exr \
	    2>&1 > log/HEVC$numStr"-2020PQ1kHEVC-709VRHEVC-XYZOCES.txt"	
	    
	# compare SRC to 444
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp.exr tmp444.exr \
	    2>&1 > log/self$numStr"-SRC-444.txt"
	    	    
	# compare 444 to YUV
	$EDRHOME/Tools/demos/sc/sigma_compare_PQ tmp444.exr tmpRTYUV.exr \
	    2>&1 > log/self$numStr"-444-YUV.txt"
	    	
	    	
	 if [ "$num" -gt 1 ]
	 then
	   break  # Skip entire rest of loop.
	 fi	    	
	    	
done


exit


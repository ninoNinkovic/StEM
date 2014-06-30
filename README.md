Handful of testing scripts:

StEM-2020PQ1k.sh:  Converts from HDR graded StEM into a PQ container with Rec2020 color range and 1,000 nit range and writes 10bit data into a yuv file.

encode2020PQ1k-10b.sh: x265 encodes the yuv file from the above script.


StEM-709VR.sh:  Converts from HDR graded StEM to 709 SDR material and writes 10 bit data into a yuv file.

encode709VR-8b-sh: x265 encodes the yuv file from the 709 step

SC-StEM-2020PQ1k.sh: basic analysis step to review workflow loss from yuv, HEVC and compare against downconversions to non HDR 709 all via ACES ODT process. 

The idea will be to round trip the PQ HDR 1k limted data through HEVC then apply a SDR 709 ODT and compare the result of that playback to the 709 content created by HEVC encodings of StEM-709VR.sh content using sigma_compare.


Requirements:

Some CTL scripts from: https://github.com/quantizationbit/CTLs
ctlrender and it's requirements
x265 compiled for high bit depth
mpv player or other ways to play encodings

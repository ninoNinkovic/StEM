Handful of testing scripts:

StEM-2020PQ1k.sh:  Converts from HDR graded StEM into a PQ container with Rec2020 color range and 1,000 nit range and writes 10bit data into a yuv file.

StEM-2020CL-PQ1k.sh: Same as above but for Rec 2020 Constant Luminance

encode2020PQ1k-10b.sh: x265 encodes the yuv file from the above scripts.


StEM-709VR.sh:  Converts from HDR graded StEM to 709 SDR material and writes 10 bit data into a yuv file.

encode709VR-8b-sh: x265 encodes the yuv file from the 709 step

SC-StEM-2020PQ1k.sh: basic analysis step to review workflow loss from yuv, HEVC and compare against downconversions to non HDR 709 all via ACES ODT process. 

The idea will be to round trip the PQ HDR 1k limted data through HEVC then apply a SDR 709 ODT and compare the result of that playback to the 709 content created by HEVC encodings of StEM-709VR.sh content using sigma_compare.


Requirements:

Some CTL scripts from: https://github.com/quantizationbit/CTLs
ctlrender and it's requirements
x265 compiled for high bit depth
mpv player or other ways to play encodings

Reccommended directory structure:

$EDRHOME : base directory for all projects, contains folders for utilities and further testing

$EDRDATA = $EDRHOME/EDRDATA : base directory for testing

$EDRHOME/ACES : base directory for AMPAS ctlrender builds, IlmLib, OpenEXR and CTL scripts

$EDRHOME/DCP : base directory for DCP testing

$EDRHOME/FF : base directory for FFMPEG builds (if needed).

$EDRHOME/HEVC : base directory for HM and x265

$EDRHOME/Tools : base directory for tools and other code (YUV, pattern, tifcmp, sigma_compare etc..)



#!/bin/sh
convert $1 \
	-fuzz 50% -trim +repage \
	-resize 1024x1024\! \
	temp0_resized.png

convert temp0_resized.png \
	-fuzz 50% -trim +repage \
	-resize 1024x1024\! \
	-fuzz 60% \
	-fill white -opaque black \
	-colorspace Gray \
	temp1.png

convert temp0_resized.png \
	-colorspace Gray \
	-edge 100 \
	temp2.png

composite temp1.png temp2.png temp1.png

convert temp1.png -resize 512x512 result.png

# -transparent white \
# -sharpen 20x2.0 \
# -edge 5 \


# +clone \
# -fill White -colorize 100%% \
# -background Black -flatten \
# -morphology Dilate Disk:20 \
# -blur 0x1 \
# -alpha Copy \
# -fill Red -colorize 100%% \
# +swap \
# -composite \


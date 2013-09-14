# dieses script rendert alle svg-dateien als *png in verschiedenen auflösungen
# The script also exports all backgrounds as black with zero opacity.

for scale in 4 5 6 7 8; do
	prefix=$(expr $scale \* 8)
	echo Prefix $prefix
	resolution=$(expr $scale \* 18)
	echo Resolution $resolution
done

for scale in 4 5 6 7 8; do
	prefix=$(expr $scale \* 8)
	resolution=$(expr $scale \* 18)
	resolutionCredits=$(expr $scale \* 32)

	echo -----------------------------------------------------
	echo Saving images: prefix=$prefix, resolution=$resolution
	echo -----------------------------------------------------

	cd credits
	for infile in *.svg; do
		if [[ $1 == '' || $infile == $1 ]]; then
			outfile=../../../images/credits/${prefix}${infile%.*}.png
			inkscape -f $infile -C -d $resolutionCredits --export-background=#000000 --export-background-opacity=0 -e $outfile
		fi
	done
	cd ..


done

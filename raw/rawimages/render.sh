# dieses script rendert alle svg-dateien als *png in verschiedenen auflösungen

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
	
	for infile in *.svg; do
		if [[ $1 == '' || $infile == $1 ]]; then
			outfile=../../images/${prefix}${infile%.*}.png
			inkscape -f $infile -C -d $resolution -e $outfile
		fi
	done

	cd menu
	for infile in *.svg; do
		if [[ $1 == '' || $infile == $1 ]]; then
			outfile=../../../images/menu/${prefix}${infile%.*}.png
			inkscape -f $infile -C -d $resolution -e $outfile
		fi
	done
	cd ..

	cd world
	for infile in *.svg; do
		if [[ $1 == '' || $infile == $1 ]]; then
			outfile=../../../images/world/${prefix}${infile%.*}.png
			inkscape -f $infile -C -d $resolution -e $outfile
		fi
	done
	cd ..

	cd credits
	for infile in *.svg; do
		if [[ $1 == '' || $infile == $1 ]]; then
			outfile=../../../images/credits/${prefix}${infile%.*}.png
			inkscape -f $infile -C -d $resolutionCredits -e $outfile
		fi
	done
	cd ..

	cd tilesets
	for infile in *.svg; do
		if [[ $1 == '' || $infile == $1 ]]; then
			outfile=../../../images/tilesets/${prefix}${infile%.*}.png
			inkscape -f $infile -C -d $resolution -e $outfile
		fi
	done
	cd ..

done

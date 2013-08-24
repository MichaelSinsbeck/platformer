# dieses script rendert alle svg-dateien als *png in verschiedenen auflösungen

for scale in 4 5 6 7 8; do
	prefix=$(expr $scale \* 8)
	echo $prefix
	resolution=$(expr $scale \* 18)
	echo $resolution
done

for scale in 4 5 6 7 8; do
	prefix=$(expr $scale \* 8)
	resolution=$(expr $scale \* 18)
	for infile in *.svg; do
		outfile=../images/${prefix}${infile%.*}.png
		inkscape -f $infile -C -d $resolution -e $outfile
	done

	cd menu
	for infile in *.svg; do
		outfile=../../images/menu/${prefix}${infile%.*}.png
		inkscape -f $infile -C -d $resolution -e $outfile
	done
	cd ..

	cd world
	for infile in *.svg; do
		outfile=../../images/world/${prefix}${infile%.*}.png
		inkscape -f $infile -C -d $resolution -e $outfile
	done
	cd ..
done

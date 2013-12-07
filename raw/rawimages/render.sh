#!/bin/bash
# dieses script rendert alle svg-dateien als *png in verschiedenen auflösungen
# The script also exports all backgrounds as black with zero opacity.
# Give a pattern as a first argument to only render the images matching that pattern.

echo "Found"
echo "$@"

for scale in 4 5 6 7 8; do
	prefix=$(expr $scale \* 8)
	echo Prefix $prefix
	resolution=$(expr $scale \* 18)
	echo Resolution $resolution
done

containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 1; done
  return 0
}

for scale in 4 5 6 7 8; do
	prefix=$(expr $scale \* 8)
	resolution=$(expr $scale \* 18)
	resolutionCredits=$(expr $scale \* 32)

	echo -----------------------------------------------------
	echo Saving images: prefix=$prefix, resolution=$resolution
	echo -----------------------------------------------------
	
	for infile in *.svg; do
		containsElement $infile $@ 
		if [[ $# == 0 || $? == 1 ]]; then
			outfile=../../images/${prefix}${infile%.*}.png
			inkscape -f $infile -C -d $resolution --export-background=#000000 --export-background-opacity=0 -e $outfile
		fi
	done

	cd menu
	for infile in *.svg; do
		containsElement $infile $@ 
		if [[ $# == 0 || $? == 1 ]]; then
			outfile=../../../images/menu/${prefix}${infile%.*}.png
			inkscape -f $infile -C -d $resolution --export-background=#000000 --export-background-opacity=0 -e $outfile
		fi
	done
	cd ..

	cd world
	for infile in *.svg; do
		containsElement $infile $@ 
		if [[ $# == 0 || $? == 1 ]]; then
			outfile=../../../images/world/${prefix}${infile%.*}.png
			inkscape -f $infile -C -d $resolution --export-background=#000000 --export-background-opacity=0 -e $outfile
		fi
	done
	cd ..

	cd credits
	for infile in *.svg; do
		containsElement $infile $@ 
		if [[ $# == 0 || $? == 1 ]]; then
			outfile=../../../images/credits/${prefix}${infile%.*}.png
			inkscape -f $infile -C -d $resolutionCredits --export-background=#000000 --export-background-opacity=0 -e $outfile
		fi
	done
	cd ..

	cd tilesets
	for infile in *.svg; do
		containsElement $infile $@ 
		if [[ $# == 0 || $? == 1 ]]; then
			outfile=../../../images/tilesets/${prefix}${infile%.*}.png
			inkscape -f $infile -C -d $resolution --export-background=#000000 --export-background-opacity=0 -e $outfile
		fi
	done
	cd ..
	
done

resolution=$(expr 8 \* 18)
cd transition
	for infile in *.svg; do
		containsElement $infile $@ 
		if [[ $# == 0 || $? == 1 ]]; then
			outfile=../../../images/transition/${infile%.*}.png
			inkscape -f $infile -C -d $resolution --export-background=#000000 --export-background-opacity=0 -e $outfile
		fi
	done
cd ..



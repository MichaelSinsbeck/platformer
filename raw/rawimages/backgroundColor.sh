# this script changes the background color of all .svg file to black

prefix=$(expr $scale \* 8)
resolution=$(expr $scale \* 18)
resolutionCredits=$(expr $scale \* 32)

echo -----------------------------------------------------
echo Changing background color to: #000000
echo -----------------------------------------------------

for infile in *.svg; do
	echo $infile
	sed -i 's/pagecolor="#ffffff"/pagecolor="#000000"/g' $infile
done

cd menu
for infile in *.svg; do
	echo menu/$infile
	sed -i 's/pagecolor="#ffffff"/pagecolor="#000000"/g' $infile
done
cd ..

cd world
for infile in *.svg; do
	echo world/$infile
	sed -i 's/pagecolor="#ffffff"/pagecolor="#000000"/g' $infile
done
cd ..

cd credits
for infile in *.svg; do
	echo credits/$infile
	sed -i 's/pagecolor="#ffffff"/pagecolor="#000000"/g' $infile
done
cd ..

cd tilesets
for infile in *.svg; do
	echo tilesets/$infile
	sed -i 's/pagecolor="#ffffff"/pagecolor="#000000"/g' $infile
done
cd ..


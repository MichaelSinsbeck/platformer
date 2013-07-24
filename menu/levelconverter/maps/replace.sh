for i in *.tmx
do
  sed -i 's/,25,/,11,/g' $i
  sed -i 's/,26,/,17,/g' $i
  sed -i 's/,27,/,12,/g' $i
  sed -i 's/,28,/,5,/g' $i
  sed -i 's/,29,/,6,/g' $i
done


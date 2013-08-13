for i in *.tmx
do
  sed -i 's/tilewidth="100"/tilewidth="50"/g' $i
  sed -i 's/tileheight="100"/tileheight="50"/g' $i
  sed -i 's/tilewidth="80"/tilewidth="40"/g' $i
  sed -i 's/tileheight="80"/tileheight="40"/g' $i
done

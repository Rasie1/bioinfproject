 #!/bin/sh
for file in `ls` 
do 
	if [ $file in `cat bad_images.txt` ] then 
	      rm $file 
	      break
	fi
done;

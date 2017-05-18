#!/bin.bash
for i in {1..10}
do
	A=`head -c 500 /dev/urandom | tr -dc a-zA-Z | tr [a-z] [A-Z]|head -c 1`B=`head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 6`C=`echo $RANDOM|cut -c 2`
	echo $A$B$C
done 

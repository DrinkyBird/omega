#!/bin/bash
# Patchmaker 9000 by Dusk
#
# Usage: ./patchmaker.sh <older> <newer> <output>
# Creates an output file which contains all files from <newer> which are
# different than the ones in <older>.
#
# This is a rather intensive process but does show progess output.

A_DIR=.PATCHMAKER_A_DIR
B_DIR=.PATCHMAKER_B_DIR
C_DIR=.PATCHMAKER_C_DIR

rm -rf $A_DIR $B_DIR $C_DIR

echo "Extract $1..."
unzip $1 -d $A_DIR >/dev/null
echo "Extract $2..."
unzip $2 -d $B_DIR >/dev/null
mkdir $C_DIR

cd $B_DIR

i=0
j=0
FILES=$( find )
NUMFILES=$( echo $FILES |wc -w )

for f in $FILES; do
	if [ -d $f ]; then
		let i+=1
		continue;
	fi
	
	if [ ! -e ../$A_DIR/$f ]; then
		let i+=1
		continue;
	fi
	
	MD5A=$( md5sum ../$A_DIR/$f |awk '{printf $1}' )
	MD5B=$( md5sum $f |awk '{printf $1}' )
	if [ "$MD5A" != "$MD5B" ]; then
		echo -en "                                                         \r"
		echo -e "$f"
		
		mkdir -pv ../$C_DIR/$( dirname $f )
		cp -v $f ../$C_DIR/$f
		
		let j+=1
	fi
	
	let i+=1
	perc=$( expr $i \* 100 / $NUMFILES )
	perc2=$( expr $j \* 100 / $NUMFILES )
	echo -ne "\r$i / $NUMFILES: $perc% ($j: $perc2%)"
done

echo

cd ../$C_DIR
zip -r9 ../$3 *

cd ..
rm -rf $A_DIR $B_DIR $C_DIR
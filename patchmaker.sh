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

function cleanup {
	echo "Cleaning up..."
	rm -rf $A_DIR $B_DIR $C_DIR
}

if [ -z "$3" ]; then
	echo "Usage: $0 <older> <newer> <output>" >/dev/stderr
	echo "Creates a patch file which contains files in <newer> which " >/dev/stderr
	echo "are different than their counterparts on <older>." >/dev/stderr
	exit 1
fi

cleanup

echo "Extracting archives..."
unzip $1 -d $A_DIR >/dev/null && \
	unzip $2 -d $B_DIR >/dev/null

if [ ! -d $A_DIR -o ! -d $B_DIR ]; then
	echo "Failed to extract $1 and $2!" >/dev/stderr
	cleanup
	exit 1
fi

mkdir $C_DIR

cd $B_DIR

i=0
j=0
FILES=$( find )
NUMFILES=$( echo $FILES |wc -w )

# Iterate through the files and see which ones have changed
for f in $FILES; do
	if [ -d $f ]; then
		# Directory - skip
		let i+=1
		continue;
	fi
	
	# Generate MD5 sums of the two files. If they are different, we add this file
	# to the new patch.
	MD5A=$( md5sum ../$A_DIR/$f 2>/dev/null |awk '{printf $1}' )
	MD5B=$( md5sum $f 2>/dev/null |awk '{printf $1}' )
	
	if [ "$MD5A" != "$MD5B" ]; then
		# Make sure that a directory exists for the file or cp will fail
		mkdir -p ../$C_DIR/$( dirname $f )
		
		# Copy the file now
		cp $f ../$C_DIR/$f
		
		let j+=1
	fi
	
	# Write some output to show progress
	let i+=1
	perc=$( expr $i \* 100 / $NUMFILES )
	perc2=$( expr $j \* 100 / $NUMFILES )
	echo -ne "\rProcessed: $i / $NUMFILES ($perc%); Patched: $j ($perc2%)"
done

# Write a terminating newline
echo

cd ../$C_DIR
zip -r9 ../$3 *

if [ "$?" != "0" ]; then
	echo "Failed to create output file $3!" >/dev/stderr;
	cd ..
	cleanup
	exit 1
fi

cd ..
cleanup

echo "Patch file $3 created."
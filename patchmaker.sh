#!/bin/bash
# Patchmaker 9000 by Dusk
#
# Usage: ./patchmaker.sh <older> <newer> <output>
# Creates an output file which contains all files from <newer> which are
# different than the ones in <older>.
#
# This is a rather intensive process but does show progess output.

a_dir=.PATCHMAKER_a_dir
b_dir=.PATCHMAKER_b_dir
c_dir=.PATCHMAKER_c_dir

function cleanup {
	echo "Cleaning up..."
	rm -rf $a_dir $b_dir $c_dir
}

if [ -z "$3" ]; then
	echo "Usage: $0 <older> <newer> <output>" >/dev/stderr
	echo "Creates a patch file which contains files in <newer> which " >/dev/stderr
	echo "are different than their counterparts on <older>." >/dev/stderr
	exit 1
fi

# We need clean temp directories first
cleanup

# Try extract the archives
echo "Extracting archives..."
unzip $1 -d $a_dir >/dev/null && \
	unzip $2 -d $b_dir >/dev/null

# If the archives could not be extracted, we can't continue.
if [ ! -d $a_dir -o ! -d $b_dir ]; then
	echo "Failed to extract $1 and $2!" >/dev/stderr
	cleanup
	exit 1
fi

# Enter the newer archive
cd $b_dir

numprocessed=0
numpatched=0
files=$( find )
numfiles=$( echo $files |wc -w )

# Iterate through the files and see which ones have changed
for f in $files; do
	# Skip any directories
	if [ -d $f ]; then
		let numprocessed+=1
		continue;
	fi
	
	# Generate MD5 sums of the two files. If they are different, we add this file
	# to the new patch.
	md5_a=$( md5sum ../$a_dir/$f 2>/dev/null |awk '{printf $1}' )
	md5_b=$( md5sum $f 2>/dev/null |awk '{printf $1}' )
	
	if [ "$md5_a" != "$md5_b" ]; then
		# Make sure that a directory exists for the file or cp will fail
		mkdir -p ../$c_dir/$( dirname $f )
		
		# Copy the file now
		cp $f ../$c_dir/$f
		
		let numpatched+=1
	fi
	
	# Write some output to show progress
	let numprocessed+=1
	processed_perc=$( expr $numprocessed \* 100 / $numfiles )
	patched_perc=$( expr $numpatched \* 100 / $numfiles )
	echo -ne "\rProcessed: $numprocessed / $numfiles ($processed_perc%); Patched: $numpatched ($patched_perc%)"
done

# Write a terminating newline
echo

cd ../$c_dir
zip -r9 ../$3 *

# Error if zip fails
if [ "$?" != "0" ]; then
	echo "Failed to create output file $3!" >/dev/stderr;
	cd ..
	cleanup
	exit 1
fi

cd ..
cleanup

echo "Patch file $3 created."
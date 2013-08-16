#!/bin/bash

if [ -z "$(which git)" ]; then
	echo "no git installed" >/dev/stderr
	exit 1
fi

if [ -z "$(which acc)" ]; then
	echo "no acc installed" >/dev/stderr
	exit 1
fi

zipcompression=$1
if [ -z "$1" ]; then
	zipcompression=0
fi

for util in acsconstants acschangelog; do
	if [ ! -x "./utils/$util" ]; then
		if [ -e ./utils/$util.c ]; then
			cc=gcc
			source=$util.c
		else
			cc=g++
			source=$util.cpp
		fi
		
		echo "Compiling $source..."
		$cc -o ./utils/$util -W -Wall ./utils/$source
		
		if [ "$?" != "0" ]; then
			exit 1;
		fi
	fi
done

revnum=$(git describe |sed "s/-/ /g" |awk '{printf $2}')
if [ "$(git status --short)" != "" ]; then
	revnum="${revnum}m"
fi

branch=$(git rev-parse --abbrev-ref HEAD)

fname="aow2_omega-$branch-r$revnum.pk3"

if [ -e tmp ]; then
	echo "tmp exists, delete it?"
	rm -rI tmp
	
	if [ -e tmp ]; then
		echo "tmp was not removed"
		exit 1
	fi
fi

mkdir tmp
pushd tmp >/dev/null
	mkdir -p acs acs_src actors
	
	../utils/acschangelog ../changelog.txt ./acs_src/a_changelog.acs
	
	pushd acs >/dev/null
		acc_args="-I ../../utils/acc -I ../acs_src/ ../../src/acs_src/aow2scrp.acs aow2scrp.o"
		echo "Compiling ACS..."
		acc $acc_args # >/dev/null 2>&1
		
		if [ ! -e aow2scrp.o ]; then
			# acc $acc_args
			exit 1
		fi
	popd >/dev/null
	
	../utils/acsconstants ../src/acs_src/aow2scrp.acs actors/acsconstants.dec
	exitcode=$?
	if [ "$exitcode" != "0" ]; then
		echo "Failed to generate DECORATE constants (exit code: $exitcode)"
		exit 1
	fi
	
	zip -r -$zipcompression ../$fname actors acs * >/dev/null
popd >/dev/null

pushd src >/dev/null
	echo "Building $fname..."
	zip -r -$zipcompression ../$fname acs * >/dev/null
popd >/dev/null

rm -rf ./tmp/

echo "done!"

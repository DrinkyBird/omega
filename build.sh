#!/bin/bash

if [ -z "$(which git)" ]; then
	echo "no git installed" >/dev/stderr
	exit 1
fi

if [ -z "$(which acc)" ]; then
	echo "no acc installed" >/dev/stderr
	exit 1
fi

if [ ! -x "./utils/acsconstants" ]; then
	echo "ACS constants utility doesn't exist, compiling..."
	gcc -o ./utils/acsconstants -W -Wall ./utils/acsconstants.c
	
	if [ "$?" != "0" ]; then
		exit 1;
	fi
	
	echo "ACS constants utility ready."
fi

revnum=$(git describe |sed "s/-/ /g" |awk '{printf $2}')
if [ "$(git status --short)" != "" ]; then
	revnum="${revnum}m"
fi

branch=$(git rev-parse --abbrev-ref HEAD)

fname="omega-$branch-r$revnum.pk3"

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
	mkdir acs actors
	pushd acs >/dev/null
		acc_args="-I ../../utils/acc ../../src/acs_src/aow2scrp.acs aow2scrp.o"
		echo "Compiling ACS..."
		acc $acc_args # >/dev/null 2>&1
		
		if [ ! -e aow2scrp.o ]; then
			# acc $acc_args
			exit 1
		fi
	popd >/dev/null
	
	../utils/acsconstants ../src/acs_src/aow2scrp.acs actors/acsconstants.txt
	exitcode=$?
	if [ "$exitcode" != "0" ]; then
		echo "Failed to generate DECORATE constants (exit code: $exitcode)"
		exit 1
	fi
	
	zip -r -$1 ../$fname actors acs * >/dev/null
popd >/dev/null

pushd src >/dev/null
	echo "Building $fname..."
	zip -r -$1 ../$fname acs * >/dev/null
popd >/dev/null

rm -rf ./tmp/

echo "done!"

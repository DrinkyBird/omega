@echo off
setlocal enableExtensions enableDelayedExpansion
set tmp=TEMPFILE
set Path=%PATH%;%cd%\utils;%cd%\utils\acc

if exist tmp goto tmpexists
:doneremovingtmp

git describe >%tmp%
set /p descrb=<%tmp%
if "%descrb%"=="" (	
	echo no git installed
	pause
	goto :eof
)

gitrevnum %descrb% >%tmp%
set /p rnum=<%tmp%

rem Run git status --short to see if it's modified
git status --short >%tmp%
set /p stat=<%tmp%

rem Replace newlines in %stat%, if doesn't like them:
set ^"stat2=!stat:^

= !"

rem Now do the checking
if "%stat2%" NEQ "" set rnum=%rnum%m

set fname=omega_git-%rnum%.pk3

rem We don't need the temp file anymore
del %tmp%

md tmp
pushd tmp
	md acs
	pushd acs
		echo Compiling ACS
		acc -I ..\..\utils\acc ..\..\src\acs_src\aow2scrp.acs aow2scrp.o >nul 2>nul
		if not exist aow2scrp.o goto acsfail
	popd
	
	zip -r1 ..\%fname% acs >nul
popd
rmdir tmp /s /q >nul

echo Creating %fname%
pushd src
zip -r1 ..\%fname% * >nul
popd

echo done!
pause
goto :eof

rem ===============================================================================
rem State tags
:tmpexists
echo tmp already exists, need to remove it to continue
rmdir /s tmp
if exist tmp goto abort
goto doneremovingtmp

:acsfail
rem Execute ACC a second time to expose the error
acc -I ..\..\utils\acc ..\..\src\acs_src\aow2scrp.acs aow2scrp.o

echo ACS failed to compile, aborting
goto abort

:abort
echo stop
pause
goto :eof
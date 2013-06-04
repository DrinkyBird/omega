@echo off
setlocal enableExtensions enableDelayedExpansion
set tmp=TEMPFILE
set Path=%PATH%;%cd%\utils;C:\Program Files\Git\cmd;C:\Program Files (x86)\Git\cmd

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

set fname=omega_xweps_git-%rnum%.pk3

rem We don't need the temp file anymore
del %tmp%

echo Creating %fname%
pushd xweps
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
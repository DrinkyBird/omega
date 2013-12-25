@echo off
setlocal enableExtensions enableDelayedExpansion
set tmp=TEMPFILEd
set Path=%PATH%;%cd%\utils;%cd%\utils\acc;C:\Program Files\Git\cmd;C:\Program Files (x86)\Git\cmd

if exist tmp goto tmpexists
:doneremovingtmp

rem Run git status --short to see if it's modified
git status --short >%tmp%
set /p stat=<%tmp%

rem Replace newlines in %stat%, if doesn't like them:
set ^"stat2=!stat:^

= !"

git describe >%tmp%
set /p descrb=<%tmp%
if "%descrb%"=="" (	
	echo no git installed
	pause
	goto :eof
)

set dsc=initial-293-g1932f81
for /f "tokens=1,2,3 delims=-" %%a in ("%dsc%") do set tag=%%a&set revnum=%%b&set cset=%%c
set cset=%cset:~-7%

git rev-parse --abbrev-ref HEAD >%tmp%
set /p branch=<%tmp%

rem Now do the checking
if "%stat2%" NEQ "" set revnum=%revnum%m

if "%branch%" EQ "master" (
	set fname=aow2-omega-r%revnum%-%cset%.pk3
) else (
	set fname=aow2-omega-%branch%-r%revnum%-%cset%.pk3
)

rem We don't need the temp file anymore
del %tmp%

md tmp
pushd tmp
	md acs
	md actors
	md acs_src

	..\utils\acschangelog.exe ..\changelog.txt acs_src\a_changelog.acs

	pushd acs
		echo Compiling ACS
		acc -I ..\..\utils\acc -I ..\acs_src\ ..\..\src\acs_src\aow2scrp.acs aow2scrp.o >nul 2>nul
		if not exist aow2scrp.o goto acsfail
	popd

	..\utils\acsconstants.exe ..\src\acs_src\aow2scrp.acs actors\acsconstants.dec
	zip -r1 ..\%fname% acs actors acs_src >nul
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
acc -I ..\..\utils\acc -I ..\acs_src\ ..\..\src\acs_src\aow2scrp.acs aow2scrp.o

echo ACS failed to compile, aborting
goto abort

:abort
echo stop
pause
goto :eof

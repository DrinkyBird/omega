@echo off
setlocal enableextensions disabledelayedexpansion
set tmp=TEMPFILE
set Path=%PATH%;%cd%\utils;%cd%\utils\acc

if exist tmp goto tmpexists
:doneremovingtmp

git describe >%tmp%
set /p descrb=<%tmp%
if "%descrb%"=="" goto nogit

gitrevnum %descrb% >%tmp%
set /p rnum=<%tmp%

rem See if it's modified
git status --short >%tmp%
set /p statustext=<%tmp%
if NOT "%statustext%"=="" set rnum=%rnum%m
:donewithmodified

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

echo Creating %fname%
pushd src
zip -r1 ..\%fname% * >nul
popd src

rd /s /q tmp >nul
del /a /f tmp >nul
echo done!
pause
goto :eof

rem ===============================================================================
rem State tags
:nogit
echo no git installed
pause
goto :eof

:tmpexists
set /p yesreallydelete=directory named tmp already exists, remove it? (Y/N)
if "%yesreallydelete%"=="y" goto removetemp
if "%yesreallydelete%"=="Y" goto removetemp
echo aborting operations
pause
goto :eof

:removetemp
rd /s /q tmp >nul
goto doneremovingtmp

:acsfail
rem Execute ACC a second time to expose the error
acc -I ..\..\utils\acc ..\..\src\acs_src\aow2scrp.acs aow2scrp.o

echo ACS failed to compile, aborting
pause
goto :eof
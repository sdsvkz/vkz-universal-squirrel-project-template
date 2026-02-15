@echo off

cd /D "%~dp0"
call lib\vkzlib\build.bat
cd /D "%~dp0"
call src\build.bat

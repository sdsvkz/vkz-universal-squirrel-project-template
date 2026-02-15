@echo off

cd /D "%~dp0"

set build_script_file=..\lib\vkzlib\build.py

echo "Building src..."
python %build_script_file% build.json

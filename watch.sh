#!/bin/bash
onchange -v -p 250 './*.asm' './src/*.asm' './objs/*.asm' -- sh -c 'echo compiling && dasm stardust.asm -Isrc -Iaudio -Ivisual -ostardust.nes -f3 -v2 -llisting.txt && echo launching && cmd.exe /C start stardust.nes'
# dasm -sromsym.txt will export symbol file

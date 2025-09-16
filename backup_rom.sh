#!/bin/bash

count=$(ls -1q exports/ | wc -l)
padding_length=4
padded_count=$(printf "%0${padding_length}d" "$count")
new_name="stardust__$padded_count.nes"	
	
echo $new_name 
cp stardust.nes exports/$new_name

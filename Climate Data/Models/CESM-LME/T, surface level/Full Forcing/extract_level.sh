#!/bin/bash
# This is a shell script to extract the surface of a multi-level dataset

# Get the names of the files
FILES=b*

# Extract the bottom level
for f in $FILES
do
# Extract by doing the average over the level of interest
#
# To specify the level of interest, change the index in the lev,index,index line
ncea -d lev,30,30 -F $f surface.$f
done

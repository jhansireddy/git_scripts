#!/bin/bash
#set -x

# @see http://stevelorek.com/how-to-shrink-a-git-repository.html

# Shows you the largest objects in your repo's pack file.
# Written for osx.
#
# @see http://stubbisms.wordpress.com/2009/07/10/git-script-to-show-largest-pack-objects-and-trim-your-waist-line/
# @author Antony Stubbs

# set the internal field separator to line break, so that we can iterate easily over the verify-pack output
IFS=$'\n';

# list all objects including their size, sort by size, take top 10
objects=`git verify-pack -v .git/objects/pack/pack-*.idx | grep -v chain | sort -k3nr | head`

echo "All sizes are in MB. The pack column is the size of the object, compressed, inside the pack file."

output="size,pack,SHA,location\n----,----,---,--------"
for y in $objects
do
  # extract the size in MB
  size=`echo $y | cut -f 5 -d ' '`
  # extract the compressed size in MB
  compressedSize=`echo $y | cut -f 6 -d ' '`
  # extract the SHA
  sha=`echo $y | cut -f 1 -d ' '`
  # find the objects location in the repository tree
  other=`git rev-list --all --objects | grep $sha`
  location=${other//$sha /}
  output="${output}\n${size},${compressedSize},${sha},${location}"
done

echo -e $output | column -t -s ','

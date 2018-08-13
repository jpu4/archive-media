#!/bin/bash

# James Ussery <James@Ussery.me>
#
# Loop through folders and compress and rename media 
#
# My folder structure:
# 2001/01-jan/
# 2001/02-feb/somerandomdir
# 2001/03-mar/
# 2001/04-apr/
# 2001/05-may/somerandomdir
# 2001/06-jun/
# 2002/01-jan/
# 2002/02-feb/somerandomdir1/somerandomdir2
# 
# Usage: sh ./optimize.sh 
# Usage: sh ./optimize.sh "starting dir"

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

DateTimeFormat="%Y%m%d_%H%M%S%3N"
DateStamp=$(date +"%Y%m%d")
DateTime=$(date +"%Y%m%d_%H%M%S%3N")

start_dir=${1:-`pwd`}       # set to current directory or user supplied directory

# Enable special handling to prevent expansion to a
# literal '/tmp/backup/*' when no matches are found. 
shopt -s nullglob

# Array of folders under start directory
dirs=($start_dir*)

# Loop through directories
for d in "${dirs[@]}"
   do
   # Validate that it's actually a directory
    if [ -d "$d" ]; then

     echo " ======= "
     echo "Processing ${d}"
     echo " ======= "
    
    # Read all filenames into an array
    fileArray=($(find $d* -type f ))
    
    # get length of the array
    tLen=${#fileArray[@]}
    
    # use for loop to read all the filenames
    for (( i=0; i<${tLen}; i++ ));
        do
        
        file="${fileArray[$i]}"

            # Validate that it's actually a file
             if [ -f "$file" ]; then

                filepath=$(dirname "${file}")
                
                MIMETYPE=`file -b --mime-type $file`

                 # Position of extension (without dot)
                 extpos=${#file}-3 
                 # Store the extension
                 ext=${file:$extpos:4}
                 # echo "File extension: " $ext
                 extlc="$(echo $ext | tr '[A-Z]' '[a-z]')"

                # Assign rules to process files based on type
                case $MIMETYPE in 
                    "application/x-gzip"|"text/plain"|"text/x-shellscript"|"application/zip"|"application/x-rar-compressed"|"application/octet-stream")

                        # do nothing (Skip it)
                        echo "Processing rules for $file"
                        echo "No rules for $file ...skipping"

                    ;;
                    "video/x-msvideo"|"video/quicktime"|"video/3gp"|"video/mpeg")
                    # Shrink video files and output as mp4, 
                    # copy metadata to match then delete the old.

                        echo "Processing rules for $file"
                        newfile="$filepath/$(date -r "$file" +"%Y%m%d_%H%M%S%3N").mp4"
                        echo "filepath=$filepath"
                        echo "newfile=$newfile"
                        ffmpeg -i $file -c:v libx264 -crf 30 $newfile

                        chmod --reference="$file" "$newfile"
                        chown --reference="$file" "$newfile"
                        touch --reference="$file" "$newfile"
                        
                        rm -rf $file

                    ;;
                    "image/x-thm"|"application/x-paradox")

                        echo "Processing rules for $file"
                        rm -rf $file
                    ;;
                    "image/jpeg")

                        echo "Processing rules for $file"
                        jpegoptim -bPpvt -m 70 $file
                        jhead -autorot -nf%Y%m%d_%H%M%S%03i $file

                    ;;
                    *)

                        echo "Processing rules for $file"
                        newfile=$filepath"/$(date -r "$file" +"%Y%m%d_%H%M%S")$(( $RANDOM % 100 )).$extlc"
                        mv -n "$file" "`echo $newfile | tr '[A-Z]' '[a-z]'`"

                    ;;
                esac
            fi
     done

    # Compress processed directories
    echo "Compressing $d"
    # tar -cvzf $d.tar.gz $d
    cd $filepath
    cwd=${PWD##*/}
    cd ..
    echo $cwd
    pwd
    tar -cvzf $d.tar.gz $cwd/
    # Test Tar (Dry Run)
    # tar -cvzf - $d | wc -c
    fi
done

# Unset shell option after use, if desired. Nullglob is unset by default.
shopt -u nullglob

# restore $IFS
IFS=$SAVEIFS
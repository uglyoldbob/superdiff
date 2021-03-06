#!/bin/sh
NOCOLOR='\033[0m'
OLD_ROOT=$1
NEW_ROOT=$2

DIFFCMD="diff -Naur"
OUTFILE="./diff.patch"

list_files() {
 for entry in "$OLD_ROOT/$1"*
 do
  if test -f "$entry"; then
    printf "%s/\n" ${entry/$OLD_ROOT\//}
  fi
 done
 for entry2 in "$NEW_ROOT/$1"*
 do
   if test -f "$entry2"; then
    if [ ! -e ${entry2/$NEW_ROOT/$OLD_ROOT} ]; then
 	printf "%s/\n" ${entry2/$NEW_ROOT\//}
    fi
   fi
 done
}

list_folders() {
 for entry in "$OLD_ROOT/$1"*
 do
  if test -d "$entry"; then
    printf "%s/\n" ${entry/$OLD_ROOT\//}
  fi
 done
 for entry2 in "$NEW_ROOT/$1"*
 do
   if test -d "$entry2"; then
    if [ ! -e ${entry2/$NEW_ROOT/$OLD_ROOT} ]; then
        printf "%s/\n" ${entry2/$NEW_ROOT\//}
    fi
   fi
 done
}

remove_dot_slash() {
 printf "$1" | sed 's/\.\///'
}

diff_all_files() {
 printf "Diffing all files in $1\n"
 ENTRIES=$(remove_dot_slash "$(list_files $1)")
 for entry in $ENTRIES
 do
   $DIFFCMD $OLD_ROOT$entry $NEW_ROOT$entry >> $OUTFILE
 done
}

diff_some_files() {
 printf "Diffing some files in $1\n"
 ENTRIES=$(remove_dot_slash "$(list_files $1)")
 for entry in $ENTRIES
 do
   read -n1 -p "Diff $entry? (y/n)" choice
   case "$choice" in
     y|y ) $DIFFCMD $OLD_ROOT$entry $NEW_ROOT$entry >> $OUTFILE ;;
     * ) ;;
   esac
   printf "\n"
 done
}


diff_files() {
 printf "$1:\n"
 read -n1 -p "Diff files in this directory? (all/some/none)" choice
 case "$choice" in
  a|A ) echo "OK"
    diff_all_files $1;;
  s|S ) echo "Some"
    diff_some_files $1;;
  n|N ) echo "OOK";;
  * ) echo "WHAT?";;
 esac
 echo "Was passed " $1
}

diff_folder() {
 printf "$1:\n"
 ENT=$(list_folders "$1")
 printf $ENT
 printf "\n"
 ENTRIES=$(remove_dot_slash "$ENT")
 for things in $ENTRIES
 do
   printf "$things :\n"
   read -n1 -p "Directory diff? (all/some/none)" choice
   case "$choice" in
     a|A ) printf "Diffing the whole folder: %s\n" $things
       $DIFFCMD $OLD_ROOT/$1 $NEW_ROOT/$1 >> $OUTFILE;;
     s|S ) printf "Entering directory for evaluation: %s\n " $things
	diff_folder "$things";;
     * ) echo "Ignoring";;
   esac 
 done
 diff_files $1
 
# read -n1 -p "Directory diff? (all/some/none)" choice
# case "$choice" in
#   a|A ) echo "Diffing the whole folder"
#     $DIFFCMD $OLD_ROOT$1 $NEW_ROOT$1 >> $OUTFILE;;
#   s|S ) echo "Entering directory for evaluation";;
#   * ) echo "Ignoring";;
# esac 
}

#for entry in "$1"/*
#do
#  if test -d "$entry"; then
#    echo -e '\033[0;36m' "FOLDER " "$entry"
#  elif test -f "$entry"; then
#    echo -e '\033[0;32m' "FILE " "$entry"
#  fi
#done
echo -e $NOCOLOR
#echo "FILES FILES"
#remove_dot_slash "$(list_files ".")"
#echo "FOLDERS FOLDERS"
#remove_dot_slash "$(list_folders ".")"
#echo "FDSASDFDSASDF ASD FJDSASDFDSA ASJDFDJSASDF"
ENTRIES=$(remove_dot_slash "$(list_folders "./")")
for things in $ENTRIES
do
  echo "ITEM: " $things
#  diff_folder $things
done
diff_folder "./"
echo -e $NOCOLOR

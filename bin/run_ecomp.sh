#!/bin/bash

SVN_REPO=$1
PROJECT_DIR=$2
FILE_GLOB=$3

if [[ -z "$SVN_REPO" || -z "$PROJECT_DIR" || -z "$FILE_GLOB" ]]; then
  echo Usage: `basename $0` svn_repository_url target_project_dir file_glob
  exit -1
fi

ECOMP_DIR=`dirname $0`/../

SVN_REVISION=`svn log -r 1:HEAD -l 1 $SVN_REPO | tail -n+2 | head -n 1 | awk '{ print substr($1, 2) }'`
END_SVN_REVISION=$(svn info $SVN_REPO | grep "^Last Changed Rev: " | awk '{ print $4 }')
TRANSLATE_AUTHOR=`which translate_bbc_username.pl`
REPORT_DIRECTORY=`pwd`/$PROJECT_DIR/reports

if [ ! -d "$PROJECT_DIR" ];
then
  git svn clone --authors-prog $TRANSLATE_AUTHOR -r $SVN_REVISION:$END_SVN_REVISION $SVN_REPO $PROJECT_DIR
  cd $PROJECT_DIR
else
  cd $PROJECT_DIR
  git svn rebase --authors-prog $TRANSLATE_AUTHOR
fi

if [ ! -d "reports" ];
then
  mkdir "reports"
fi

metrics $REPORT_DIRECTORY "$FILE_GLOB"
ln -sf $REPORT_DIRECTORY $ECOMP_DIR/public/data/$PROJECT_DIR 

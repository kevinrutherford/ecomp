#!/bin/bash

SCRIPTDIR=`dirname $0`

PROJECT_ROOT=`pwd`

if [ ! -e "$SCRIPTDIR/ObjC.tokens" ]; then
	cd $SCRIPTDIR
	java -jar /usr/local/lib/antlr-4.4-complete.jar ObjC.g4
	javac ObjC*.java
	cd -
fi

if [ -z "$1" ]; then
	echo Usage: $0 objective_c_dot_m_file
	exit -1
fi

TMPDIR=`mktemp -d -t ecomp`
SOURCEFILE=`basename "$1"`
SRCDIR=`dirname "$1"`
ABSSOURCEFILE="$PROJECT_ROOT/$SRCDIR/$SOURCEFILE"

CLASSNAME=`echo $SOURCEFILE | awk '{ print substr($1, 1, length($1)-2) }'`
HEADERFILE=$CLASSNAME.h
ABSHEADERFILE="$SRCDIR/$HEADERFILE"

LEXOUT=$TMPDIR/$CLASSNAME.lex

cd $SCRIPTDIR
java org.antlr.v4.runtime.misc.TestRig ObjC lex -tokens $ABSSOURCEFILE | grep -v "#import \"$HEADERFILE\"" > $LEXOUT
IMPORTS=$(grep "<132>" "$LEXOUT" | wc -l | tr -d [:blank:])
CONDITIONALS=$(grep "<43>" "$LEXOUT" | wc -l | tr -d [:blank:])
ANDS=$(grep "<91>" "$LEXOUT" | wc -l | tr -d [:blank:])
ORS=$(grep "<92>" "$LEXOUT" | wc -l | tr -d [:blank:])
TERNARIES=$(grep "<85>" "$LEXOUT" | wc -l | tr -d [:blank:])
FORLOOPS=$(grep "<41>" "$LEXOUT" | wc -l | tr -d [:blank:])
WHILELOOPS=$(grep "<64>" "$LEXOUT" | wc -l | tr -d [:blank:])
CONDITONAL_COUNT=$(echo $CONDITIONALS + $ANDS + $ORS + $TERNARIES + $WHILELOOPS + $FORLOOPS | bc)

SUPERCLASSCOUNT=0
HLEXOUT=$TMPDIR/$CLASSNAME.hlex
if [ -e "$ABSHEADERFILE" ]; then
	java org.antlr.v4.runtime.misc.TestRig ObjC lex -tree "$ABSHEADERFILE" | tr '(' '\n' > $HLEXOUT
	SUPERCLASSNAME=$(grep "class_name $CLASSNAME)" $HLEXOUT -A1 | tail -n 1)

	if [ -z "$(echo $SUPERCLASSNAME | grep NSObject)" ]; then
		SUPERCLASSCOUNT=1
	fi
fi

echo "{"
echo "  \"filename\": \"$SRCDIR/$SOURCEFILE\","
echo "  \"num_branches\": $CONDITONAL_COUNT,"
echo "  \"num_dependencies\": $IMPORTS,"
echo "  \"num_superclasses\": $SUPERCLASSCOUNT"
echo "}"

rm -rf $TMPDIR

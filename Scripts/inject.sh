#! /bin/sh -e

SCRIPTPATH=$(dirname "$0")
TEMPLATES=${TEMPLATES:-"$SCRIPTPATH/../Templates"}

if [ -n "SOURCERY_BINPATH" ]; then
  SOURCERY_BINPATH="$SOURCERY_BINPATH"
elif [ -f "$PODS_ROOT/Sourcery/bin/sourcery" ]; then
  SOURCERY_BINPATH="$PODS_ROOT/Sourcery/bin/sourcery"
else
  SOURCERY_BINPATH="sourcery"
fi

if [ -n "INJECT_OUTPUT" ]; then
  INJECT_OUTPUT="$INJECT_OUTPUT"
else
  INJECT_OUTPUT="$SRCROOT/Generated/"
fi

if [ -n "INJECT_INPUT" ]; then
  INJECT_INPUT="$INJECT_INPUT"
else
  INJECT_INPUT="$SRCROOT"
fi

set -x

"$SOURCERY_BINPATH" --templates "$TEMPLATES" --sources "$INJECT_INPUT" --output "$INJECT_OUTPUT" "$@"
# ./Pods/Sourcery/bin/sourcery --templates ./Templates 

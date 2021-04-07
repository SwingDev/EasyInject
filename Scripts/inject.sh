#! /bin/sh -e

SCRIPTPATH=$(dirname "$0")
TEMPLATES=${TEMPLATES:-"$SCRIPTPATH/../Templates"}

if [ -z "SOURCERY_BINPATH" ]; then
  SOURCERY_BINPATH="$SOURCERY_BINPATH"
elif [ -f "$PODS_ROOT/Sourcery/bin/sourcery" ]; then
  SOURCERY_BINPATH="$PODS_ROOT/Sourcery/bin/sourcery"
else
  SOURCERY_BINPATH="sourcery"
fi

if [ -z "INJECT_OUTPUT" ]; then
  INJECT_OUTPUT="$SRCROOT/Generated/"
else
  INJECT_OUTPUT="$INJECT_OUTPUT"
fi

if [ -z "INJECT_INPUT" ]; then
  INJECT_INPUT="$SRCROOT"
else
  INJECT_INPUT="$INJECT_INPUT"
fi

set -x

"$SOURCERY_BINPATH" --templates "$TEMPLATES" --sources "$INJECT_INPUT" --output "$INJECT_OUTPUT" "$@"
# ./Pods/Sourcery/bin/sourcery --templates ./Templates 

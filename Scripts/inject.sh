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

ARGS=""

if [ -n "$NO_MOCKS" ]; then
  ARGS="noMocks,$ARGS"
fi

if [ -n "$LEGACY_INJECTION" ]; then
  ARGS="legacyInjection,$ARGS"
fi

if [ -n "$IMPORTS" ]; then
  ARGS="imports=$IMPORTS,$ARGS"
fi

if [ -n "$TEST_IMPORTS" ]; then
  ARGS="testImports=$TEST_IMPORTS,$ARGS"
fi

echo "Extra: $EXTRA"
echo "Args: $ARGS"

"$SOURCERY_BINPATH" --templates "$TEMPLATES" --sources "$INJECT_INPUT" --output "$INJECT_OUTPUT" --args "$ARGS" "$EXTRA" "$@"
# ./Pods/Sourcery/bin/sourcery --templates ./Templates 

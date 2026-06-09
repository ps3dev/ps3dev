#!/bin/sh

set -eu

case "$PS3DEV" in
  /*) ;;
  *)
    echo "ERROR: \$PS3DEV must be an absolute path."
    exit 1
    ;;
esac

case "$PS3DEV" in
  *" "*)
    echo "ERROR: \$PS3DEV must not contain spaces."
    exit 1
    ;;
esac

mkdir -p "$PS3DEV" || {
  echo "ERROR: Could not create $PS3DEV."
  exit 1
}

test_file="$PS3DEV/.ps3dev-write-test"
touch "$test_file" || {
  echo "ERROR: $PS3DEV is not writable."
  exit 1
}
rm -f "$test_file"

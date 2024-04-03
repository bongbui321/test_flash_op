#!/bin/bash -e

if [ $# -ne 1 ]; then
  echo "Error: Exactly one argument is required."
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
EDL=$DIR/edl/edl

if [[ ! -f  $EDL ]]; then
  echo "Installing edl..."
  {
    git clone https://github.com/bkerler/edl
    cd $DIR/edl
    git fetch --all
    git checkout 81d30c9039faf953881d38013ced01d1a06429db
    git submodule update --depth=1 --init --recursive
    pip3 install -r requirements.txt
    cd $DIR
  } &> /dev/null
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Installing libusb for macOS..."
  {
    brew install libusb
    ln -s /opt/homebrew/lib ~/lib
  } &> /dev/null
fi

echo "Getting active slot..."
CURRENT_SLOT="$($EDL getactiveslot 2>&1 | grep "Current active slot:" | cut -d ':' -f2- | sed 's/[[:blank:]]//g')"
if [ "$CURRENT_SLOT" == "a" ]; then
  OTHER_SLOT="b"
elif [ "$CURRENT_SLOT" == "b" ]; then
  OTHER_SLOT="a"
else
  echo "Current slot invalid: '$CURRENT_SLOT'"
  exit 1
fi
echo "Current active slot: $CURRENT_SLOT"

dump() {
  $EDL r $1 $2 --memory=ufs
}


if [ "$1" == "after" ]; then
  mkdir after_flash &> /dev/null
  for part in system xbl xbl_config devcfg boot aop abl; do
    dump ${part}_$CURRENT_SLOT after_flash/${part}_test.img
  done

  echo "Checking correctness of flashed partitions..."
  python3 checkhash.py after
fi


if [ "$1" == "before" ]; then
  mkdir before_flash &> /dev/null
  for part in system xbl xbl_config devcfg boot aop abl; do
    partition=${part}_$OTHER_SLOT
    $EDL e $partition
    dump $partition before_flash/${part}_test.img
  done

  echo "Checking other slot before flashing..."
  python3 checkhash.py before
fi

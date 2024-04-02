#!/bin/bash -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
EDL=$DIR/edl/edl

echo "Enter your computer password if prompted"

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
  NEW_SLOT="b"
elif [ "$CURRENT_SLOT" == "b" ]; then
  NEW_SLOT="a"
else
  echo "Current slot invalid: '$CURRENT_SLOT'"
  exit 1
fi

read_and_checksum() {
  echo "Read and checksum $1..."
  {
    $EDL r $1 $2 --memory=ufs
    sha256sum $2 > $3
  } &> /dev/null
}

for part in aop xbl xbl_config devcfg boot system; do
  partition=${part}_$NEW_SLOT
  $EDL e $partition
  read_and_checksum $partition ${part}_before_flash.img ${part}_before_flash_checksum
  echo "${part}_before_flash_checksum"
done

boot_correct_hash="f0de74e139b8b99224738d4e72a5b1831758f20b09ff6bb28f3aaaae1c4c1ebe"
abl_correct_hash="eeb89a74c968a5a2ffce96f23158b72e03e2814adf72ef59d1200ba8ea5d2f39"
xbl_correct_hash="bcef195b00a1ab685da601f4072722569773ab161e91c8753ad99ca4217a28f5"
xbl_config_correct_hash="19791056558c16f8dae787531b5e30b3b3db2ded9d666688df45ce1b91a72bac"
devcfg_correct_hash="be44b73dda5be840b09d5347d536459e31098da3fea97596956c0bdad19bdf27"
aop_correct_hash="5d764611a683d6a738cf06a1dcf8a926d0f47b5117ad40d3054167de6dd8bd0f"
system_correct_hash="0f69173d5f3058f7197c139442a6556be59e52f15402a263215a329ba5ec41e2"

for part in aop xbl xbl_config devcfg boot system; do
  read_and_checksum ${part}_$NEW_SLOT ${part}_test.img ${part}_checksum
  if [ "${part}_checksum" != $($"${part}_correct_hash") ]; then
    echo "Found unmatched for partition ${part}"
    exit 1
  fi
done

echo "All partition checksum match"

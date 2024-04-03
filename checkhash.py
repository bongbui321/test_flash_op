import sys
import hashlib
import json
import requests
import os

MASTER_MANIFEST = "https://raw.githubusercontent.com/commaai/openpilot/master/system/hardware/tici/agnos.json"

def read_and_check_hash(filename, size, hash):
  if os.path.isfile(filename):
    bytes_to_write = size
    sha256 = hashlib.sha256()
    with open(filename, 'rb') as f:
      while (bytes_to_write > 0):
        rlen = min(1024*1024, bytes_to_write)
        chunk = f.read(rlen)
        sha256.update(chunk)
        bytes_to_write -= rlen
    return sha256.hexdigest().lower() == hash.lower()

def load_manifest(url):
  r = requests.get(url)
  r.raise_for_status()
  return json.loads(r.content.decode())

if __name__ == "__main__":
  expected = sys.argv[1]
  all_good = True
  update = load_manifest(MASTER_MANIFEST)
  read_dir = "after_flash" if expected == "after" else "before_flash"

  for partition in update:
    ret = read_and_check_hash(f"{read_dir}/{partition['name']}_test.img", partition['size'], partition['hash_raw'])
    if expected == "after":
      if not ret:
        print(f"Unmatched: {partition['name']}")
        all_good = False
    elif expected == "before":
      if ret:
        print(f"The hash in partitions {partition['name']} is the same as the expected hash, make sure to erase the partition prior for testing purposes")
        all_good = False
    else:
      print("Either \"same\" or \"not_same\" as argument")

  if all_good:
    if expected == "after":
      print(f"All flashed partitions are correct")
    elif expected == "before":
      print("The flashing partitions are different from flashing images, good to flash")
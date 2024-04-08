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
    partition_hash = sha256.hexdigest().lower()
    return partition_hash  == hash.lower(), partition_hash

def load_manifest(url):
  r = requests.get(url)
  r.raise_for_status()
  return json.loads(r.content.decode())

if __name__ == "__main__":
  check = sys.argv[1]
  unmatched_partitions = {}
  update = load_manifest(MASTER_MANIFEST)
  read_dir = "after_flash" if check == "after" else "before_flash"

  for partition in update:
    ret, partition_hash = read_and_check_hash(f"{read_dir}/{partition['name']}_test.img", partition['size'], partition['hash_raw'])
    if (check == "after" and not ret) or (check == "before" and ret):
      unmatched_partitions[partition['name']] = {"incorrect": partition_hash, "correct": partition["hash_raw"]}

  if len(unmatched_partitions) == 0:
    print("All good!")
  else:
    for k, v in unmatched_partitions.items():
      if check == "after":
        print(f"Partition: {k}")
        print(f"Partition hash: {v['incorrect']}")
        print(f"Expected hash: {v['correct']}\n")
      elif check == "before":
        print(f"Partition {k} currently having correct image, needed to be erased first")

# TEST PLAN FOR FLASH TESTING

- [x] Correct checksum for every flashed partition
  - [x] Erase the flashing partition first + get hash + check hash
  - [x] Flash the partition + get hash + check hash
- [x] Website stops when the device disconnects (no frozen tab)
  - [x] Unplug in the middle of flashing partitions
  - [x] Unplug in the middle of changing slots
  - [x] Unplug fast in the beginning when was handshaking with Sahara
- [x] Check gpt header correctness after changing slot (similar to that of fastboot)
  - [x] edl gpt dump `./edl printgpt --memory=ufs`
- [x] Recover gpt header after a crash during changing active slot
  - [x] Use `./edl setactiveslot $other_slot` -> this would emulate a situation where the primary gpt header is different from backup gpt header, then use the flash website. It would recover the correct gpt header from backup.
- [x] Flash to the correct slot if it fails the previous time
  - [x] similar testing method as above
- [x] No corrupted backup gpt header partition even if the users plug in the device immediately after a fail flash
  - [x] The `xbl_$currentslot` is deleted before flashing so it is impossible to do that. Checked by unplug during changing slot and try to turn on the device -> no turn on -> no backup gpt header update -> no corrupted backup gpt header.


## Checking partition hash dump:
### 1 . Run before flashing:
```bash
# Run this command before flashing to check that the flashing slot partitions don't have the images
# This erases the flashing partitions before the flash and check the data within them
./test_flash before
```
### 2. Use [bongbui321.github.io/flash](bongbui321.github.io/flash) to flash the device
### 3. Turn on and follow the instruction to reset your device
  - This is for the backup gpt header to be updated to the correct primary header. We check the active slot using the backup gpt header since it is more reliable than the primary gpt header, and based on our implementation, backup gpt header would always in non-corrupted state
### 4. Run after flashing:
```bash
# Run this command after flashing to check that the flashing slot partitions are the same as the images
# This reads the flashed partitions and compute the hash + check with the hash of the images
./test_flash after
```

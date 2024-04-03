# TEST PLAN FOR FLASH TESTING

- [x] Correct checksum for every flashed partition
  - [x] Erase the flashing partition first + get checksum
  - [x] Flash the partition and check with checksum
- [ ] Website stops when the device disconnects (no frozen tab)
- [ ] Check gpt header correctness after changing slot (similar to that of fastboot)
- [ ] Recover gpt header after a crash during changing active slot
- [ ] Flash to the correct slot if it fails the previous time

Optional
- [ ] No corrupted gpt header partition even if the users plug in the device immediately after a fail flash

## Usage
### 1 . Run before flashing:
```bash
# Run this command before flashing to check that the flashing slot partitions don't have the images
./test_flash before
```
### 2. Use [bongbui321.github.io/flash](bongbui321.github.io/flash) to flash the device
### 3. Turn on and follow the instruction to reset your device
  - This is for the backup gpt header to be updated to the correct primary header
### 4. Run after flashing:
```bash
# Run this command after flashing to check that the flashing slot partitions are the same as the images
./test_flash after
```

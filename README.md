## TEST PLAN FOR FLASH TESTING

- [ ] Correct checksum for every flashed partition
  - [ ] Erase the flashing partition first + get checksum
  - [ ] Flash the partition and check with checksum
- [ ] Website stops when the device disconnects (no frozen tab)
- [ ] Check gpt header correctness after changing slot (similar to that of fastboot)
- [ ] Recover gpt header after a crash during changing active slot
- [ ] Flash to the correct slot if it fails the previous time

Optional
- [ ] No corrupted gpt header partition even if the users plug in the device immediately after a fail flash
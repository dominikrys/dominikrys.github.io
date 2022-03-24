---
title: "How to Debug srsLTE"
date: 2021-02-13T10:34:48+01:00
cover:
    image: "img/srslte-logo.png"
    alt: "srsLTE Logo"
tags:
  - security
  - engineering
  - c++
  - srslte
  - lte
---

I've recently been working extensively with [srsLTE](https://github.com/srsLTE/srsLTE) for my bachelor's dissertation. So far, the greatest difficulty has been debugging the software. In this short post, I will describe various ways I found that srsLTE can be debugged, and any pitfalls that come with them.

I'll assume you know how to debug ordinary C/C++ programs (I'll patiently wait here if you need to have a look into that).

## Compiling srsLTE in Debug Mode

Your first attempt at debugging may have been to compile with the `Debug` CMake flag, and then executing the binaries using GDB or another debugger:

```bash
cmake ../ -DCMAKE_BUILD_TYPE=Debug
```

**This will probably work for srsEPC**, but you may have trouble with srsENB and srsUE as the code most likely won't get past the Random Access Procedure (RAP). Due to how time-sensitive the RAP is, binaries in `Debug` mode are too slow and are unable to complete the procedure. However, if what you need to debug occurs before the RAP, this method will most likely be sufficient.

Alternatively, srsLTE can be built in **release with debug info** mode, which will reliably get past the RAP:

```bash
cmake ../ -DCMAKE_BUILD_TYPE=RelWithDebInfo
```

An issue with this is that plenty of code will be optimised out, so you may not hit the breakpoints you need. Sporadic segmentation faults may also occur, so your mileage may vary.

As an extra caveat, **using SDRs while running srsLTE may not be possible** due to the extra latency introduced by the debugger. I've tried using the Ettus Research USRP B200 and B210 while debugging, and the UHD driver constantly times out for both. Instead, the [ZeroMQ](https://docs.srslte.com/en/latest/app_notes/source/zeromq/source/) driver will most likely need to be used while debugging.

### When Release with Debug Info Doesn't Work

For many issues, I had to resort to print statements. This is just about good enough for most issues, especially combined with srsLTE logging if it's cranked up to the `debug` level.

Increasing `all_hex_limit` inside the `.conf` files from 32 to something greater can also help if you're inspecting various messages/objects, as it will allow for more hex to be printed in the logs.

#### Printing Hex in the Console

To ease debugging, a quick hack can be added to srsLTE for allowing objects to be printed in the console. This is particularly useful for printing certain PDUs of interest. To achieve this in srsLTE 20.04.2, add following code to `log_filter.cc`:

```cpp
void log_filter::console_hex(const uint8_t* hex, int size)
{
  console(hex_string(hex, size).c_str());
}
```

The appropriate headers will also need to be changed in `log.h` and `log_filter.h`. Objects can then by printed as hex by calling:

```cpp
log->console_hex(pdu->msg, pdu->N_bytes);
```

## Successful Debugging in a VM

If debugging in debug mode is _really_ necessary, A VM can be used as a last resort. I found that it's possible there to get past the RAP with srsLTE built in `Debug` mode. Note that SDRs will most likely not work due to the latency introduced by the VM, in which case the srsLTE ZeroMQ driver will need to be used instead.

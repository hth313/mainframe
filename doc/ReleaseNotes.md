# HP-41CL mainframe (firmware) release notes

## Version IFG, Time 3A, Extended Functions 4A

September 29, 2019

### Highlights

* This update provides 23K of extended memory (3405 registers)
  for the HP-41CL by making use of the RAM address range 400-EFF.
  This means 5.5 times more extended memory than any HP-41 ever had
  in the past.

* As before, the size of a single file is limited by the amout of
  available memory. All affected functions, such as `SEEKPT`, `RESZFL`,
  `FLSIZE`, `EMDIR` etc, have been updated to work with the larger file
  sizes now available.

* As a file now can have more than 999 registers, EMDIR has been modified to
  display 4 digit file sizes when needed. The space separator will also
  be replaced by a '.' (dot) when all digits in the LCD are needed for
  file information. This happens for files with 7 letter filenames and
  a file size of 1000 or more registers.

* EMDIR now shows additional file types.
  - M - CCD matrix file
  - B - I/O buffer file
  - K - Key assignments file
  - S - Status registers
  - Z - Complex stack for 41Z
  - L - LIFO file (for Doug Wilder's LIFO functions)
  - F - Forth code
  - H - Binary stack for HP-16C
  - W - Write all registers file


### Important information

* Due to that the low level routines for addressing the extended
  memory have changed, any plug-in module that uses copied old routines
  can no longer be used. The old code makes certain assumptions that
  are no longer valid and will most likely cause corruption of the
  extended memory if used.
  Modules that call the entries in the HP-41CX/CL OS will still work.


### Corrections

* A bug in looking up an XROM when two modules with the same XROM ID
  were present has been corrected. This bug could show itself in
  different ways. The most well known misbehavior is that executing an
  `XROM dd,25` with two modules with identity `dd` plugged in and the
  first had fewer than 25 instructions, the calculator would instead
  execute `INSREC`. Another way is that if an Extended Functions
  module is plugged into an HP-41CX or HP-41CL, executing `EMROOM`
  would incorrectly result in `NONEXISTENT`.

* Execute key direct (XKD) with plug-in MCODE XROM functions only worked
  in program  mode. In run-mode it would instead go through the
  ordinary preview and NULL test. XKD now works properly in both
  program and run-mode. Typical built-in XKD instructions are `R/S`
  and `SST`. The only module that is known to make use of the XKD
  feature in XROM is the Ladybug module.

* Fixed the bug where a prompting XROM function when giving an IND ST
  operand would merge the postfix operand with the first byte of the
  XROM (overwriting its second byte), causing either a NONEXISTENT
  or executing the wrong instruction.


### Minor changes

* The calculator can now perform a master clear (MEMORY LOST) about
  twice as fast compared to before. The reason for this is that it
  is only needed to clear RAM page 0 and 1. Pages 2 and 3 was also
  cleared before and resulted in that the extended memory was fully
  cleared. However, this is not necessary as the routines that deal
  with extended memory do not rely on having the additional RAM pages
  cleared. This was observed and commented on as early as 3/26/1979 by
  DRC (Dave R Conklin), but was left as is. Now that there are
  additional pages for extended memory, the choice was to either make
  a master clear take even longer, or just reduce it to the really
  required pages 0 and 1.

* The `PCTOC` routine is now one word time faster.

* The extra timing annotations for the HP-41CL differs slightly from the
  original NFL image. This is mostly related to the Time module where it
  was sometimes too cautions.

* Correct the `CAT 2` speed in turbo mode. The delay loop was
  executing too fast, which made it impossible to see what was going
  on when a key was held down to speed it up further.

* The Time module now has a proper tail identity again. The previous NFL
  image for HP-41CL borrowed that area for code. This has been slightly
  reworked to preserve existing behavior while retaining the module
  identity.
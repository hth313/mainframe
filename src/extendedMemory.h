#ifndef _EXTENDED_MEMORY_H
#define _EXTENDED_MEMORY_H

;;; Set up or making additional Extended Memory pages using flat memory
#ifndef HighestXMemPage
#define HighestXMemPage 14
#endif

#if HighestXMemPage > 15 || HighestXMemPage < 4
#error "Highest X Memory page not within 4-15"
#endif

#define XMEM_REGISTERS (600 + 2 + (255 * (HighestXMemPage - 3)))

#endif // _EXTENDED_MEMORY_H

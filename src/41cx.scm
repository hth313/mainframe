(define memories
  '((memory NUT0 (bank 1) (address (#x0 . #xFFF))
            (section (QUAD0 #x0) (QUAD1 #x400) (QUAD2 #x800) (QUAD3 #xC00))
            (checksum #xFFF hp41)
            (fill 0))
    (memory NUT1 (bank 1) (address (#x1000 . #x1FFF))
            (section (QUAD4 #x1000) (QUAD5 #x1400) (QUAD6 #x1800) (QUAD7 #x1C00))
            (checksum #x1FFF hp41)
            (fill 0))
    (memory NUT2 (bank 1) (address (#x2000 . #x2FFF))
            (section (QUAD8 #x2000) (QUAD9 #x2400) (QUAD10 #x2800) (QUAD11 #x2C00))
            (checksum #x2FFF hp41)
            (fill 0))
    (memory XFUNS3 (bank 1) (address (#x3000 . #x3FFF))
            (section PAGE3)
            (checksum #x3FFF hp41)
            (fill 0))
    (memory TIME (bank 1) (address (#x5000 . #x5FFF))
            (section CXTIME)
            (checksum #x5FFF hp41)
            (fill 0))
    (memory XFUNS5 (bank 2) (address (#x5000 . #x5FFF))
            (section PAGE5_2)
            (checksum #x5FFF hp41)
            (fill 0))))

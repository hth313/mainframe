SRCS_CV = cn0b.s cn1b.s cn2b.s cn3b.s cn4b.s cn5b.s cn6b.s \
       cn7b.s cn8b.s cn9b.s cn10b.s cn11b.s
OBJS_CV = $(SRCS_CV:%.s=%-cv.o)
MOD_CV = 41cv.mod

SRCS_CX = $(SRCS_CV) extfuns.s time.s extfuns2.s
OBJS_CX = $(SRCS_CX:%.s=%-cx.o)
MOD_CX = 41cx.mod

all: $(MOD_CX)

%-cv.o: %.s
	asnut -g -l$(*F)-cv.lst $< -o$@

%-cx.o: %.s
	asnut -DHP41CX -g -l$(*F)-cx.lst $< -o$@

$(MOD_CX): $(OBJS_CX) 41cx.scm 41cx.moddesc
	lnnut -g $(OBJS_CX) 41cx.scm 41cx.moddesc

$(MOD_CV): $(OBJS_CV) 41cv.scm 41cv.moddesc
	lnnut -g $(OBJS_CV) 41cv.scm 41cv.moddesc

clean:
	-rm $(OBJS_CV) $(OBJS_CX) $(MOD_CV) $(MOD_CX) 41cv 41cx *.lst

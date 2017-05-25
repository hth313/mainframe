# VPATH = cv

SRCS_CV = cn0b.s cn1b.s cn2b.s cn3b.s cn4b.s cn5b.s cn6b.s \
       cn7b.s cn8b.s cn9b.s cn10b.s cn11b.s
OBJS_CV = $(SRCS_CV:%.s=%.o)
MOD_CV = 41cv.mod

all: $(MOD_CV)

%.o: %.s
	asnut -g -l $<

$(MOD_CV): $(OBJS_CV) 41cv.scm 41cv.moddesc
	lnnut -g $(OBJS_CV) 41cv.scm 41cv.moddesc

clean:
	-rm $(OBJS_CV) $(MOD_CV) 41cv

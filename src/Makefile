SRCS_CV = cn0b.s cn1b.s cn2b.s cn3b.s cn4b.s cn5b.s cn6b.s \
       cn7b.s cn8b.s cn9b.s cn10b.s cn11b.s

SRCS_CL = $(SRCS_CV) extfuns.s time.s extfuns2.s
OBJS_CL = $(SRCS_CL:%.s=%-cl.o)
MOD_CL = 41cl.mod

all: $(MOD_CL)

%-cl.o: %.s
	asnut -DHP41CX --cpu=newt -g --list-file=$(*F)-cl.lst $< -o$@

$(MOD_CL): $(OBJS_CL) 41cx.scm 41cl.moddesc
	lnnut -g -l --output-format=MOD2 $(OBJS_CL) 41cx.scm 41cl.moddesc --output-file=$@

clean:
	-rm $(OBJS_CL) $(MOD_CL)  *.lst

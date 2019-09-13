
RPNS = xmem.rpn

SRCS = test.s
OBJS = $(RPNS:%.rpn=%.o) $(SRCS:%.s=%.o)
MOD = lb-test.mod

all: $(MOD)

%.o: %.s
	asnut -l -g $<

%.o: %.rpn
	rpncomp -I../src -l $<

$(MOD): $(OBJS) Plugin4K.scm test.moddesc
	lnnut --list-file=linker.lst -g $(OBJS) Plugin4K.scm test.moddesc

clean:
	rm $(OBJS) $(MOD)

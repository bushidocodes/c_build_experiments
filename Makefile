OBJS = greet/count.o greet/greet.o hello.o

all: link

clean:
	rm -rf *.i *.S *.o **/*.i **/*.S **/*.o hello 

.PRECIOUS: %.i 
%.i: %.c
	gcc -E -o $@ $<

.PRECIOUS: %.S 
%.S: %.i
	gcc -S -o $@ $<

%.o: %.S
	as -o $@ $<

link: $(OBJS)
	gcc -o hello $^


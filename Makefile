OBJS = greet/count.o greet/greet.o hello.o

LIB_OBJS = greet/count.o greet/greet.o

all: link

clean:
	rm -rf *.i *.S *.o **/*.i **/*.S **/*.o hello libgreet.a libgreet.so

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

# Static Archive Rules
# These demonstrate how to create a static archive from *.o object files
# And how to either directly or indirectly link the static archive

libgreet.a: $(LIB_OBJS)
	ar rcs libgreet.a $^

# The archive has to come last
link_libgreet_a_direct: hello.o libgreet.a
	gcc -o hello $^

# We set the LIBRARY_PATH environment variable so -lgreet finds ./libgreet.a
link_libgreet_a_indirect: hello.o libgreet.a
	LIBRARY_PATH=. gcc -o hello hello.o -lgreet

# Dynamic Archive Rules
# These demonstrate how to create a shared library from *.o object files
# And how to either directly or indirectly link the static archive

libgreet.so: $(LIB_OBJS)
	gcc -shared -o libgreet.so $^

link_libgreet_so: hello.o libgreet.so
	gcc -L. -o hello hello.o -lgreet

# Example of running the resulting binary. We need to set LD_LIBRARY_PATH to the directory of libgreet.so
hello_so: link_libgreet_so
	LD_LIBRARY_PATH=. ./hello

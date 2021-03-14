CC = gcc
AS = as
AR = ar
APP_OBJS = hello.o
LIB_OBJS = greet/count.o greet/greet.o
OBJS = $(APP_OBJS) $(LIB_OBJS)

all: link

clean:
	rm -rf *.i *.S *.ll *.o *.bc *.a *.so *.wasm **/*.i **/*.S **/*.o **/*.ll **/*.bc **/*.bca

.PRECIOUS: %.i 
%.i: %.c
	$(CC) -E -o $@ $<

.PRECIOUS: %.S 
%.S: %.i
	$(CC) -S -o $@ $<

%.o: %.S
	$(AS) -o $@ $<

link: $(OBJS)
	$(CC) -o hello $^

# Static Archive Rules
# These demonstrate how to create a static archive from *.o object files
# And how to either directly or indirectly link the static archive

libgreet.a: $(LIB_OBJS)
	$(AR) rcs libgreet.a $^

# The archive has to come last
link_libgreet_a_direct: $(APP_OBJS) libgreet.a
	$(CC) -o hello $^

# We set -L. so -lgreet finds ./libgreet.a
link_libgreet_a_indirect: $(APP_OBJS) libgreet.a
	$(CC) -L. -o hello $(APP_OBJS) -lgreet

# Dynamic Archive Rules
# These demonstrate how to create a shared library from *.o object files
# And how to either directly or indirectly link the static archive

libgreet.so: $(LIB_OBJS)
	$(CC) -shared -o libgreet.so $^

link_libgreet_so: hello.o libgreet.so
	$(CC) -L. -o hello hello.o -lgreet

# Example of running the resulting binary. We need to set LD_LIBRARY_PATH to the directory of libgreet.so
hello_so: link_libgreet_so
	LD_LIBRARY_PATH=. ./hello

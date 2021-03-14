WASI_SDK_PATH=./wasi-sdk-12.0
CC=$(WASI_SDK_PATH)/bin/clang --sysroot=$(WASI_SDK_PATH)/share/wasi-sysroot
AR=$(WASI_SDK_PATH)/bin/llvm-ar
LIB_BC_OBJS = greet/count.bc greet/greet.bc

include common.mk

.PRECIOUS: %.ll 
%.ll: %.i
	$(CC) -S -emit-llvm -o $@ $<

# Generate llvm bitcode from the text representation
.PRECIOUS: %.bc
%.bc: %.ll
	llvm-as -o $@ $<

# Assemble into WebAssembly object file
.PRECIOUS: %.o 
%.o: %.bc
	llc -march=wasm32 -filetype=obj -o $@ $< 

# Link WebAssembly object files into a module
link: $(OBJS)
	$(CC) --target=wasm32-unknown-wasi -o hello.wasm $^

libgreet.bc: $(LIB_BC_OBJS)
	llvm-link -o libgreet.bc $^

link_libgreet_bc_direct: hello.bc libgreet.bc
	$(CC) --target=wasm32-unknown-wasi -o hello.wasm $^

# Build WebAssembly using LLVM Bitcode Archive
libgreetbc.a: $(LIB_BC_OBJS)
	$(AR) rcs libgreetbc.a $^

link_libgreetbc_a_direct: hello.bc libgreetbc.a
	$(CC) --target=wasm32-unknown-wasi -o hello.wasm $^

# The LIBRARY_PATH environment variable was ignored, using -L instead
link_libgreetbc_a_indirect: hello.bc libgreetbc.a
	$(CC) -L. --target=wasm32-unknown-wasi -o hello.wasm hello.bc -lgreetbc



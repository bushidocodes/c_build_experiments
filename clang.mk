CC = clang
AR = ar
AS = as
LIB_BC_OBJS = greet/count.bc greet/greet.bc

include common.mk

# Compile preprocessed C source code into the LLVM IR text representation
.PRECIOUS: %.ll 
%.ll: %.i
	$(CC) -S -emit-llvm -o $@ $<

# Assemble the LLVM IR text format into bitcode
.PRECIOUS: %.bc
%.bc: %.ll
	llvm-as -o $@ $<

# Compile llvm bitcode into native assembly
.PRECIOUS: %.S 
%.S: %.bc
	llc --relocation-model=pic -o $@ $<

# Assemble native assembly into native ELF object file
.PRECIOUS: %.o 
%.o: %.S
	$(AS) -o $@ $< 

# Link the native object files of the application and library into and executable
link: $(OBJS)
	$(CC) -o hello $^

############################
### Static Archive Rules ###
############################

# Create static archive libgreet.a from its component *.o object files
libgreet.a: $(LIB_OBJS)
	$(AR) rcs libgreet.a $^

# Link native object files with the static archive libgreet.a, forming an executable
# Note: the archive has to come last
link_libgreet_a_direct: $(APP_OBJS) libgreet.a
	$(CC) -o hello $^

# Link native object files with the static archive libgreet.a, forming an executable
# In this context, indirect means that the -lgreet forces the linker to search for libgreet.a
# The search path includes the current directory because of -L.
link_libgreet_a_indirect: $(APP_OBJS) libgreet.a
	$(CC) -L. -o hello $(APP_OBJS) -lgreet

############################
### Shared Library Rules ###
############################

# Create dynamic shared library libgreet.so from its component *.o object files
libgreet.so: $(LIB_OBJS)
	$(CC) -shared -o libgreet.so $^

# Link native object files with the shared library, forming an executable
# The libgreet symbols are not in the resulting executable and have to be loaded dynamically at runtime 
link_libgreet_so: $(APP_OBJS) libgreet.so
	$(CC) -L. -o hello $(APP_OBJS) -lgreet

# Example of running the resulting binary. We need to set LD_LIBRARY_PATH to the directory of libgreet.so
# or the executable will not be able to dynamically link to libgreet.so at runtime
hello_so: link_libgreet_so
	LD_LIBRARY_PATH=. ./hello

##############################################
### Static *.bc LLVM Bitcode Library Rules ###
##############################################

# Link the LLVM bitcode of different translation units into a single *.bc file
libgreet.bc: $(LIB_BC_OBJS)
	llvm-link -o libgreet.bc $^

# Link the native ELF object file of the application with the single *.bc file containing the static LLVM Bitcode Library
link_libgreet_bc_direct: $(APP_OBJS) libgreet.bc
	$(CC) -o hello $^

#########################################
### Static LLVM Bitcode Archive Rules ###
#########################################

# Note: LLVM is able to generate and use archives that contains LLVM bitcode, 
# but support seems to be hit and miss
# https://stackoverflow.com/questions/60691901/how-can-i-use-llvm-ar-generated-archive-file

# Create static archive libgreetbc.a from its component *.bc LLVM Bitcode files
libgreetbc.a: $(LIB_BC_OBJS)
	llvm-ar rcs libgreetbc.a $^

# Link the native ELF object file of the application with the LLVM Bitcode Archive
link_libgreetbc_a_direct: $(APP_OBJS) libgreetbc.a
	$(CC) -fuse-ld=lld -o hello $^

# Link the native ELF object file of the application with the LLVM Bitcode Archive
# In this context, indirect means that the -lgreetbc forces the linker to search for libgreetbc.a
# The search path includes the current directory because of -L.
link_libgreetbc_a_indirect: hello.bc libgreetbc.a
	$(CC) -L. -fuse-ld=lld -o hello hello.bc -lgreetbc

/* Windows build only: libx86emu includes <sys/io.h> on x86 for direct port access, which the port never uses (all I/O goes
 * through its own handler). These stand-ins keep it compiling. */
#define inb(addr) 0xff
#define inw(addr) 0xffff
#define inl(addr) 0xffffffff
#define outb(val, addr) ((void)(val))
#define outw(val, addr) ((void)(val))
#define outl(val, addr) ((void)(val))

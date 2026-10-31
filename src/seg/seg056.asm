; Segment seg056: not yet disassembled.
	incbin	"Extracted/segments/seg056.bin", 0, 0x82F
__astart:						; MSC start-up code: the program's entry point (e_cs:e_ip)
	incbin	"Extracted/segments/seg056.bin", $ - $$

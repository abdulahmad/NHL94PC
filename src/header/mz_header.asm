; The MZ (DOS EXE) header. DOS reads it to load the program: how many bytes to load, where the relocation table is,
; how much memory to give, and where the stack and the entry point are. Sizes and offsets are worked out from the labels
; of the parts they describe, so they stay right when a segment changes size.
mz_header:
e_magic		db	'MZ'				; EXE signature
e_cblp		dw	71				; bytes used in the last 512-byte page of the load module
e_cp		dw	257				; 512-byte pages in the load module (header + image; the overlays follow it). NASM cannot
						; divide an address in another section, so this and e_cblp, e_cs are numbers
e_crlc		dw	(reloc_end - reloc_table) / 4	; number of relocation entries
e_cparhdr	dw	(image_start - $$) / 16		; header size in paragraphs: the image starts here
e_minalloc	dw	14172				; extra paragraphs needed past the image (BSS and stack)
e_maxalloc	dw	0xFFFF				; extra paragraphs wanted: all of memory
e_ss		dw	0x5400				; stack segment, relative to the image; past the end of the file (no bytes stored)
e_sp		dw	0x1800				; initial stack pointer
e_csum		dw	0x0000				; checksum (not used by DOS)
e_ip		dw	__astart			; entry point offset: the MSC start-up code
e_cs		dw	0x1B35				; entry point segment, relative to the image: segment seg056
e_lfarlc	dw	reloc_table - $$		; file offset of the relocation table
e_ovno		dw	0				; overlay number (0: the main program)

; The rest of the MZ header: two bytes after the formatted part, the relocation table (one far pointer, offset then
; segment, for every word in the image that holds a segment number; DOS adds the load segment to each), then zero fill
; up to the paragraph where the image starts.
	incbin	"Extracted/segments/mz_header.bin", 0x1C, 2
reloc_table:
	incbin	"Extracted/segments/mz_header.bin", 30, 6908
reloc_end:
	incbin	"Extracted/segments/mz_header.bin", 6938
image_start:						; end of the header: the load image starts on this paragraph

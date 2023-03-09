#ifndef JOS_INC_ELF_H
#define JOS_INC_ELF_H

#define ELF_MAGIC 0x464C457FU	/* "\x7FELF" in little endian */
// The structure is defined in the Intel 64 and IA-32 Architectures. The entry e_magic is used to identify the file as an ELF file. The entry e_elf is used to identify the file class, data encoding, and version. The entry e_type is used to identify the object file type. The entry e_machine is used to identify the required architecture for an individual file. The entry e_version is used to identify the object file version. The entry e_entry is used to identify the virtual address to which the system first transfers control, thus starting the process. The entry e_phoff is used to identify the program header table's file offset in bytes. The entry e_shoff is used to identify the section header table's file offset in bytes. The entry e_flags is used to hold processor-specific flags associated with the file. The entry e_ehsize is used to hold the ELF header's size in bytes. The entry e_phentsize is used to hold the size in bytes of one entry in the file's program header table; all entries are the same size. The entry e_phnum is used to hold the number of entries in the program header table. The entry e_shentsize is used to hold a section header's size in bytes. All section headers are the same size. The entry e_shnum is used to hold the number of entries in the section header table. The entry e_shstrndx is used to hold the section header table index of the entry associated with the section name string table. 
struct Elf {
	uint32_t e_magic;	// must equal ELF_MAGIC
	uint8_t e_elf[12];
	uint16_t e_type;
	uint16_t e_machine;
	uint32_t e_version;
	uint32_t e_entry;
	uint32_t e_phoff;
	uint32_t e_shoff;
	uint32_t e_flags;
	uint16_t e_ehsize;
	uint16_t e_phentsize;
	uint16_t e_phnum;
	uint16_t e_shentsize;
	uint16_t e_shnum;
	uint16_t e_shstrndx;
};
// The structure is defined in the Intel 64 and IA-32 Architectures. The entry p_type is used to identify the type of the segment. The entry p_offset is used to identify the offset from the beginning of the file at which the first byte of the segment resides. The entry p_va is used to identify the virtual address at which the first byte of the segment resides in memory. The entry p_pa is used to identify the physical address at which the first byte of the segment resides in memory. The entry p_filesz is used to identify the number of bytes in the file image of the segment; it may be zero. The entry p_memsz is used to identify the number of bytes in the memory image of the segment; it may be zero. The entry p_flags is used to identify the segment's flags. The entry p_align is used to identify the value to which the segments are aligned in memory and in the file. The structure is defined in the Intel 64 and IA-32 Architectures. The entry sh_name is used to identify the name of the section. The entry sh_type is used to identify the type of the section. The entry sh_flags is used to identify the attributes of the section. The entry sh_addr is used to identify the virtual address at which the first byte of the section resides in memory. The entry sh_offset is used to identify the offset from the beginning of the file at which the first byte of the section resides. The entry sh_size is used to identify the size in bytes of the section. The entry sh_link is used to identify the section index of an associated section. The entry sh_info is used to identify extra information about the section. The entry sh_addralign is used to identify the required alignment of the section. The entry sh_entsize is used to identify the size in bytes of each entry, for sections that contain fixed-size entries. The entry ELF_PROG_LOAD is used to identify the program header table's file offset in bytes. The entry ELF_PROG_FLAG_EXEC is used to identify the executable segment. The entry ELF_PROG_FLAG_WRITE is used to identify the writable segment. The entry ELF_PROG_FLAG_READ is used to identify the readable segment. The entry ELF_SECT_NULL is used to identify the null section header. The entry ELF_SECT_PROGBITS is used to identify the program-defined data section. The entry ELF_SECT_SYMTAB is used to identify the symbol
struct Proghdr {
	uint32_t p_type;
	uint32_t p_offset;
	uint32_t p_va;
	uint32_t p_pa;
	uint32_t p_filesz;
	uint32_t p_memsz;
	uint32_t p_flags;
	uint32_t p_align;
};

struct Secthdr {
	uint32_t sh_name;
	uint32_t sh_type;
	uint32_t sh_flags;
	uint32_t sh_addr;
	uint32_t sh_offset;
	uint32_t sh_size;
	uint32_t sh_link;
	uint32_t sh_info;
	uint32_t sh_addralign;
	uint32_t sh_entsize;
};

// Values for Proghdr::p_type
#define ELF_PROG_LOAD		1

// Flag bits for Proghdr::p_flags
#define ELF_PROG_FLAG_EXEC	1
#define ELF_PROG_FLAG_WRITE	2
#define ELF_PROG_FLAG_READ	4

// Values for Secthdr::sh_type
#define ELF_SHT_NULL		0
#define ELF_SHT_PROGBITS	1
#define ELF_SHT_SYMTAB		2
#define ELF_SHT_STRTAB		3

// Values for Secthdr::sh_name
#define ELF_SHN_UNDEF		0

#endif /* !JOS_INC_ELF_H */

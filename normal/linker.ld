OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64", "elf64-x86-64")

OUTPUT_ARCH(i386:x86-64)

ENTRY(_start)

/*SEARCH_DIR("=/lib/x86_64-linux-gnu");
SEARCH_DIR("=/usr/lib/x86_64-linux-gnu");
SEARCH_DIR("=/usr/lib/x86_64-linux-gnu64");
SEARCH_DIR("=/usr/local/lib64");
SEARCH_DIR("=/lib64");
SEARCH_DIR("=/usr/lib64");
SEARCH_DIR("=/usr/local/lib");
SEARCH_DIR("=/lib");
SEARCH_DIR("=/usr/lib");
SEARCH_DIR("=/usr/x86_64-linux-gnu/lib64");
SEARCH_DIR("=/usr/x86_64-linux-gnu/lib");*
SEARCH_DIR("=/usr/local/lib/x86_64-linux-gnu");*/

SEARCH_DIR("=/home/jaytee/REU/workspace/lib");

PHDRS
{
  phdrs PT_PHDR PHDRS ;
  interp PT_INTERP ; 
  header PT_LOAD FILEHDR PHDRS ;
  rodata PT_LOAD ; 
  data PT_LOAD ; 
  dynamic PT_DYNAMIC ; 
  main-text PT_LOAD ;
  sum-text PT_LOAD ;
  /*(PHDR)*/
  gnuprops PT_NOTE ; 
  abitag PT_NOTE ;
  gnuprop PT_NOTE ; 
  frames PT_GNU_EH_FRAME ; 
  stack PT_GNU_STACK ;
  relro PT_GNU_RELRO ;
}

SECTIONS
{
  PROVIDE (__executable_start = SEGMENT_START("text", 0));
  . = SEGMENT_START("text", 0) + SIZEOF_HEADERS;

  .interp         : { *(.interp) } :interp :header

  .note.gnu.property  : { *(.note.gnu.property) } :header :gnuprops :gnuprop

  .note.gnu.build-id  : { *(.note.gnu.build-id) } :header :abitag

  .note.ABI-tag   : { *(.note.ABI-tag) } :header :abitag

  .hash           : { *(.hash) } :header

  .gnu.hash       : { *(.gnu.hash) } :header

  .dynsym         : { *(.dynsym) } :header

  .dynstr         : { *(.dynstr) } :header

  .gnu.version    : { *(.gnu.version) } :header

  .gnu.version_r  : { *(.gnu.version_r) } :header

  .rela.dyn       :
    {
      *(.rela.init)
      *(.rela.text .rela.text.* .rela.gnu.linkonce.t.*)
      *(.rela.fini)
      *(.rela.rodata .rela.rodata.* .rela.gnu.linkonce.r.*)
      *(.rela.data .rela.data.* .rela.gnu.linkonce.d.*)
      *(.rela.tdata .rela.tdata.* .rela.gnu.linkonce.td.*)
      *(.rela.tbss .rela.tbss.* .rela.gnu.linkonce.tb.*)
      *(.rela.ctors)
      *(.rela.dtors)
      *(.rela.got)
      *(.rela.bss .rela.bss.* .rela.gnu.linkonce.b.*)
      *(.rela.ldata .rela.ldata.* .rela.gnu.linkonce.l.*)
      *(.rela.lbss .rela.lbss.* .rela.gnu.linkonce.lb.*)
      *(.rela.lrodata .rela.lrodata.* .rela.gnu.linkonce.lr.*)
      *(.rela.ifunc)
    } :header

  .rela.plt       :
    {
      *(.rela.plt)
      *(.rela.iplt)
    } :header

  . = ALIGN(CONSTANT (MAXPAGESIZE));

  . = SEGMENT_START("rodata", ALIGN(CONSTANT (MAXPAGESIZE)) + (. & (CONSTANT (MAXPAGESIZE) - 1)));
  
  .rodata         : { *(.rodata .rodata.* .gnu.linkonce.r.*) } :rodata

  .eh_frame_hdr   : { *(.eh_frame_hdr) *(.eh_frame_entry .eh_frame_entry.*) } :rodata :frames

  .eh_frame       : { *(.eh_frame) *(.eh_frame.*) } :rodata

  . = DATA_SEGMENT_ALIGN (CONSTANT (MAXPAGESIZE), CONSTANT (COMMONPAGESIZE));

  .init_array    :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
    KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
    PROVIDE_HIDDEN (__init_array_end = .);
  } :data :relro

  .fini_array    :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
    KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } :data :relro
  
  .dynamic        : { *(.dynamic) } :data :dynamic :relro
  
  .got            : { *(.got.plt) *(.igot.plt) *(.got) *(.igot) } :data :relro

  . = DATA_SEGMENT_RELRO_END (0, .);
  
  .data           :
  {
    *(.data .data.* .gnu.linkonce.d.*)
    SORT(CONSTRUCTORS)
  } : data

  _edata = .;
  PROVIDE (edata = .);
  __bss_start = .;

  .bss            :
  {
   *(.dynbss)
   *(.bss .bss.* .gnu.linkonce.b.*)
   *(COMMON)
   . = ALIGN(. != 0 ? 64 / 8 : 1);
  } : data

  . = ALIGN(CONSTANT (MAXPAGESIZE)); 
  
  PROVIDE (__etext = .);
  PROVIDE (_etext = .);
  PROVIDE (etext = .);

  . = ALIGN(CONSTANT (MAXPAGESIZE));

  .init.main		:	{ KEEP (main.o(SORT_NONE(.init))) } :main-text

  .plt.main		:	{ main.o(.plt) main.o(.iplt) } :main-text

  .plt.got.main	:	{ main.o(.plt.got) } :main-text

  .plt.sec.main	:	{ main.o(.plt.sec) } :main-text

  .text.main		:
  {
	main.o(.text.unlikely .text.*_unlikely .text.unlikely.*)
	main.o(.text.exit .text.exit.*)
	main.o(.text.startup .text.startup.*)
	main.o(.text.hot .text.hot.*)
	main.o(SORT(.text.sorted.*))
	main.o(.text .text.* .stub .gnu.linkonce.t.*)
	main.o(.gnu.warning)
  } :main-text

  .fini.main		:	{ KEEP (main.o(SORT_NONE(.fini))) } :main-text


  . = ALIGN(CONSTANT (MAXPAGESIZE));

  .init.sum		:	{ KEEP (sum.o(SORT_NONE(.init))) } :sum-text

  .plt.sum		:	{ sum.o(.plt) sum.o(.iplt) } :sum-text

  .plt.got.sum	:	{ sum.o(.plt.got) } :sum-text

  .plt.sec.sum	:	{ sum.o(.plt.sec) } :sum-text

  .text.sum		:
  {
	sum.o(.text.unlikely .text.*_unlikely .text.unlikely.*)
	sum.o(.text.exit .text.exit.*)
	sum.o(.text.startup .text.startup.*)
	sum.o(.text.hot .text.hot.*)
	sum.o(SORT(.text.sorted.*))
	sum.o(.text .text.* .stub .gnu.linkonce.t.*)
	sum.o(.gnu.warning)
  } :sum-text

  .fini.sum		:	{ KEEP (sum.o(SORT_NONE(.fini))) } :sum-text


  /*(SECT)*/

  . = ALIGN(64 / 8);
  _end = .; PROVIDE (end = .);
  . = DATA_SEGMENT_END (.);

}


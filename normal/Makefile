CC=gcc
OUTPUT=./a.out

all:
	cp ./buildutil/template.ld ./linker.ld ;
	for TARGET in `ls *.c` ; do $(CC) -c $$TARGET ; done ;
	for OBJECT in `ls *.o` ; do python3 ./buildutil/aslrpp.py -t=./linker.ld -o=$$OBJECT ; done ;

	# It only took a year or so to put this one together. This must be why I'm single...
	../binutils/ld/ld-new -T ./linker.ld -pie -plugin /usr/lib/gcc/x86_64-linux-gnu/11/liblto_plugin.so \
	-plugin-opt=/usr/lib/gcc/x86_64-linux-gnu/11/lto-wrapper -plugin-opt=-fresolution=/tmp/ccaZpOt3.res \
	-plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s -plugin-opt=-pass-through=-lc \
	-plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s --build-id --eh-frame-hdr -m elf_x86_64 \
	--hash-style=gnu --as-needed -dynamic-linker /lib64/ld-linux-x86-64.so.2 -pie -z now -z relro \
	/usr/lib/gcc/x86_64-linux-gnu/11/../../../x86_64-linux-gnu/Scrt1.o \
	/usr/lib/gcc/x86_64-linux-gnu/11/../../../x86_64-linux-gnu/crti.o \
	/usr/lib/gcc/x86_64-linux-gnu/11/crtbeginS.o \
	-L/usr/lib/gcc/x86_64-linux-gnu/11 -L/usr/lib/gcc/x86_64-linux-gnu/11/../../../x86_64-linux-gnu \
	-L/usr/lib/gcc/x86_64-linux-gnu/11/../../../../lib -L/lib/x86_64-linux-gnu -L/lib/../lib \
	-L/usr/lib/x86_64-linux-gnu -L/usr/lib/../lib -L/usr/lib/gcc/x86_64-linux-gnu/11/../../.. \
	-lgcc --push-state --as-needed -lgcc_s --pop-state -lc -lgcc --push-state --as-needed -lgcc_s --pop-state \
	/usr/lib/gcc/x86_64-linux-gnu/11/crtendS.o \
	/usr/lib/gcc/x86_64-linux-gnu/11/../../../x86_64-linux-gnu/crtn.o \
	`ls *.o` -o $(OUTPUT) ;

	rm `ls *.o` ;

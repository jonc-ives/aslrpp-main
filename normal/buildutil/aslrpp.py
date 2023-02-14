import sys, os, re
import subprocess

# {0} -- object name without extension
# {1} -- object name with extension

z = """  . = ALIGN(CONSTANT (MAXPAGESIZE));

  .init.{0}		:	{{ KEEP ({1}(SORT_NONE(.init))) }} :{0}-text

  .plt.{0}		:	{{ {1}(.plt) {1}(.iplt) }} :{0}-text

  .plt.got.{0}	:	{{ {1}(.plt.got) }} :{0}-text

  .plt.sec.{0}	:	{{ {1}(.plt.sec) }} :{0}-text

  .text.{0}		:
  {{
	{1}(.text.unlikely .text.*_unlikely .text.unlikely.*)
	{1}(.text.exit .text.exit.*)
	{1}(.text.startup .text.startup.*)
	{1}(.text.hot .text.hot.*)
	{1}(SORT(.text.sorted.*))
	{1}(.text .text.* .stub .gnu.linkonce.t.*)
	{1}(.gnu.warning)
  }} :{0}-text

  .fini.{0}		:	{{ KEEP ({1}(SORT_NONE(.fini))) }} :{0}-text\n

"""

y = "  {0}-text PT_LOAD ;\n"

def write_into_linker(sections, template):
	phdrs = ""
	sects = ""

	# open and buffer script
	with open(template, "r") as template:
		script = template.readlines()

	# build phdrs and sects chunks
	for sec in sections:
		phdrs += sec["phdr"] + "\n"
		sects +=  '. = ALIGN(CONSTANT (MAXPAGESIZE));\n' + sec["sect"] + "\n"

	# find and replace phdrs and sects
	for ln, line in enumerate(script):
		if line == "+ADD_PHDRS+\n":
			script[ln] = phdrs
		if line == "+ADD_SECTS+\n":
			script[ln] = sects

	# write new linker script to output
	with open(template.name, "w") as out:
		script = "".join(script)
		out.write(script)


def read_object(path):

	# yes. I'm a lazy POS
	readelf = subprocess.Popen(["readelf", "-W", "-S", path], stdout=subprocess.PIPE)
	output, errors = readelf.communicate()
	readelf.wait()


	if errors:
		sys.exit("ERROR:\tReading the indicated ELF object resulted in the following error(s):\n\t\t{0}".format(errors))

	# okay we got this far, we have a real object file
	# this splits each shdr array, filters out non-text
	# sections, and removes the name's .text. prefix

	sections = []
	for line in output.decode().splitlines():
		tok = line.split()
		if len(tok) == 0: continue

		if tok[0] == "[": tok_off = 1
		else: tok_off = 0

		if any([char.isdigit() for char in tok[tok_off]]):
			if tok[2 + tok_off] != "PROGBITS": continue
			elif tok[1 + tok_off][0:6] != ".text.": continue
			elif len(tok) != 11 + tok_off: continue
			sections.append({'secNum':re.findall(r"\d+", tok[tok_off])[0]})
			sections[-1]['name'] = tok[1 + tok_off][6:len(tok[1 + tok_off])]
			sections[-1]['type'] = tok[2 + tok_off]
			sections[-1]['offset'] = int(tok[4 + tok_off], base=16)
			sections[-1]['size'] = int(tok[5 + tok_off], base=16)
			sections[-1]['align'] = int(tok[10 + tok_off], base=16)
			sections[-1]['phdr'] = "  {} PT_LOAD ;".format(sections[-1]['name'])
			sections[-1]['sect'] = "  " + sections[-1]['name'] + " : { *(.text." + sections[-1]['name']  + ") }  :" + sections[-1]['name']
			# shouldn't usually matter
			sz = sections[-1]['size']
			sz += sz % sections[-1]['align']
			sections[-1]['loadSize'] = sz

	return sections

def main(temp, obj):

	# if we return, we good
	#tsec = read_object(obj)

	#found_names = []
	#for section in tsec:
		#if section['name'] in found_names or not section['name']:
			#section['name'] += str(section['secNum'])
		#found_names += section['name']

	# writes to copy
	#write_into_linker(obj, tsec)

	# open and buffer script
	with open(temp, "r") as _in:
		script = _in.readlines()

	# find and replace phdrs and sects
	for ln, line in enumerate(script):
		if line == "  /*(PHDR)*/\n":
			script[ln] = y.format(obj[0:-2],obj) + "  /*(PHDR)*/\n"
		if line == "  /*(SECT)*/\n":
			script[ln] = z.format(obj[0:-2],obj) + "  /*(SECT)*/\n"

	# write new linker script to output
	with open(temp, "w") as _out:
		script = "".join(script)
		_out.write(script)

	return 0


if __name__ == "__main__":

	args = sys.argv
	usage = "Usage:\tpython3 {0} -t=<template> -o=<obj_file>".format(args[0])
	if len(args) != 3:
		print(usage)

	_tf = None
	_ob = None

	# a preliminary validation
	for i, arg in enumerate(args):
		if i == 0: continue
		tok = arg.split("=")

		# need both sides
		if len(tok) != 2:
			print(usage)

		# template arg
		if tok[0] == "-t":
			if not os.path.isfile(tok[1]):
				sys.exit("ERROR:\t{0} is not a valid link-script template.".format(tok[1]))
			elif _tf != None:
				sys.exit("ERROR:\tToo many template files specified - only one allowed.")
			_tf = tok[1]

		# object arg
		elif tok[0] == "-o":
			if not os.path.isfile(tok[1]):
				sys.exit("ERROR:\t{0} is not a valid object file.".format(tok[1]))
			elif _ob != None:
				sys.exit("ERROR:\tToo many object files specified - only one allowed.")
			_ob = tok[1]

		# bad cli
		else: print(usage)

	# just in case
	if _tf and _ob:
		main(_tf, _ob)


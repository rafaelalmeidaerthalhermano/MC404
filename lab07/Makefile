arm-as := arm-elf-as
arm-ld := arm-elf-ld
asflags := -g
ldflags := -g

gpt: gpt.o
	$(arm-ld) $(ldflags) -Ttext=0 gpt.o -o gpt
gpt.o: gpt.s
	$(arm-as) $(asflags) gpt.s -o gpt.o

clean:
	-rm gpt gpt.o
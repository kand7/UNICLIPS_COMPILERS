all:
	flex -o final-flex-code.c final-flex-code.l
	gcc -o final-flex-code final-flex-code.c
	./final-flex-code in.txt out.txt
clean:
	rm final-flex-code final-flex-code.c

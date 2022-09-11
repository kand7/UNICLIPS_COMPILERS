all:
	bison -d sa.y -v
	flex la.l
	gcc -o executable sa.tab.c lex.yy.c -lfl -lm
	./executable input.txt


%option noyywrap

%{
	// Λεκτικός αναλυτής.
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "sa.tab.h"

	// Ορίζουμε μεταβλητές για να μετράμε τα στοιχεία που θέλουμε, γραμμές, σωστές και λάθος λέξεις.
	extern int line;
	extern int wrong_words;
	extern int correct_words;
	void prn(char *s);
%}

/* Ορίζουμε του κανόνες για τις "λέξεις" μας με regex. */
DELIMITER   	[ \t]+
INTS        	(0|[+-]?[1-9]+[0-9]*)
FLOATS		    [-+]?(0|[1-9]+[0-9]*)([.][0-9]+([eE][+-](0|[1-9]+[0-9]*))?|[eE][+-]?(0|[1-9]+[0-9]*))
NAMES 		   	[a-zA-Z]+((-|_)*[0-9]*[a-zA-Z]*)*
VARS		      \?([0-9]*[a-zA-Z]*)+
STRINGS 	    \"(\\[\\\"n]|[^\"\\\n])*\"
COMS		      ;.*\n
BREAKS		    [\s]+


/* Αυξάνουμε τον μετρητή των σωστών λέξεων κατα ένα κάθε φορά που εντοπιστεί μία λέξη στους
	 κανόνες του συντακτικού αναλυτή μας και επίσης επιστρέφει την τιμή σε αυτόν. Καθώς έχουμε
	 ορίσει στον συντακτικό αναλυτή η είσοδος να διαβάζεται σαν χαρακτήρες στα όπου εντοπίστεί
	 int η float πρέπει να γίνει η μετατροπή απο string σε αριθμό με τις atoi ή atof.*/
%%

{DELIMITER} 	{}
"->"			{correct_words++; return ARROW;}
"("		        {correct_words++; return BRACKETOPEN;}
")"		        {correct_words++; return BRACKETCLOSE;}

"deffacts"		{correct_words++; return DEFFACTS;}
"defrule"  		{correct_words++; return DEFRULE;}
"test"      	{correct_words++; return TEST;}
"bind"	        {correct_words++; return BIND;}
"read" 	        {correct_words++; return READ;}
"printout"	    {correct_words++; return PRINTOUT;}

"="		        {correct_words++; return EQUALS;}
"+"		        {correct_words++; return PLUSOP;}
"-"		        {correct_words++; return MINUSOP;}
"*"		        {correct_words++; return MULTOP;}
"/"		        {correct_words++; return DIVOP;}

{INTS}     	    {yylval = atoi(yytext); correct_words++; return INTS;}
{FLOATS}    	{yylval = atof(yytext); correct_words++; return FLOATS;}
{NAMES}	        {correct_words++; return NAMES;}
{VARS}		    {correct_words++; return VARS;}
{STRINGS}	    {correct_words++; return STRINGS;}
{COMS}		    {line++;}
\n		        {line++; return NL;}
.				{wrong_words++;}


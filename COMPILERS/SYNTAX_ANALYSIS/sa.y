%{
	// Συντακτικός αναλυτής.
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  // Ορίζουμε ότι η είσοδος μας θα είναι χαρακτήρες.
  #define YYSTYPE char*
  // Αρχικοποίηση των μεταβλητών μας για την μέτρηση.
  int line = 0;
  int correct_words = 0;
  int correct_syntax = 0;
  int wrong_words = 0;
  int wrong_syntax = 0;
  extern char *yytext;
  extern FILE *yyin;
  int yylex();
  int yyerror(char *s);
%}

%token ARROW BRACKETOPEN BRACKETCLOSE DEFFACTS DEFRULE TEST BIND READ PRINTOUT EQUALS PLUSOP MINUSOP MULTOP DIVOP INTS FLOATS NAMES VARS STRINGS NL

%%
// Ορίζουμε όλους τους συντακτικούς κανόνες τις uni-clips που θέλουμε να αναγνωρίζει ο αναλυτής μας.
// Κάθε φορά που εμφανίζεται σωστός κανόνας θα εμφανίζεται η γραμμή στην οποία βρίσκεται, το είδος και η ένδειξη "correct".
// Tο ίδιο θα συμβαίνει για τα σφάλματα αλλα θα εμφανίζεται ένα ερωτηματικό και η ένδειξη "error".
program:
	program NL
	|program events NL {printf("Line: %d type: event. Correct.\n", line); correct_syntax++;}
	|program deffacts NL {printf("Line: %d type: deffacts. Correct.\n", line); correct_syntax++;}
	|program defrule NL {printf("Line: %d type: defrule. Correct.\n", line); correct_syntax++;}
	|program maths NL {printf("Line: %d type: maths. Correct.\n", line); correct_syntax++;}
	|program comp NL {printf("Line: %d type: compare. Correct.\n", line); correct_syntax++;}
	|program test NL {printf("Line: %d type: test. Correct.\n", line); correct_syntax++;}
	|program bind NL {printf("Line: %d type: bind. Correct.\n", line); correct_syntax++;}
	|program printout NL {printf("Line: %d type: printout. Correct.\n", line); correct_syntax++;}
	|program error NL {printf("Line: %d type: ?. Error.\n", line); wrong_syntax++;}
	|;

// Παρακατω ορίζουμε κάποιους κανόνες που θα μας βοηθήσουν να "χτίσουμε"" τους συντακτικούς μας κανόνες.

// Ορίζουμε την αντιστοιχία των NAMES INTS ΚΑΙ VARS από τον λεκτικό αναλυτή μας.
names:
	NAMES {$$ = "NAMES";};

ints:
	INTS {$$ = "INTS";};

vars:
	VARS {$$ = "VARS";};

// Αυτός ο κανόνας μας επιτρέπει να έχουμε στην σειρά όσα απο τα παραπάνω στοιχεία θέλουμε και θα μας χρησιμέυσει για την σύνταξη των στοιχείων γεγονόντων.
elements:
	NAMES
	|INTS
	|VARS
	|elements elements;

// Μας επιτρέπει να έχουμε πολλά στοιχεία γεγονόντων στην σείρα και θα μας χρειαστεί για το defrule
events:
	BRACKETOPEN elements BRACKETCLOSE
	|events events;

// Μας επιτρέπει να έχουμε πολλά στοιχεία γεγονόντων το ένα κάτω από το άλλο και θα μας χρειαστεί για το deffacts
deffacts_events:
	BRACKETOPEN elements BRACKETCLOSE
	|deffacts_events deffacts_events
	|deffacts_events NL deffacts_events;

// Ορίζουμε τους συντακτικούς κανόνες για το deffacts.
deffacts:
	BRACKETOPEN DEFFACTS NAMES NL deffacts_events BRACKETCLOSE;

// Ορίζουμε τα στοιχεία που θα περιέχει η δήλωση μία εκτύπωσης.
print_contents:
	VARS
	|INTS
	|NAMES
	|STRINGS
	|print_contents print_contents; // Εδώ μας επιτρέπει να έχουμε όσα στοιχεία εκτύπωσης χρειάζονται.

// Ορίζουμε τους κανόνες σύνταξης του περιεχομένου της εκτύπωσης.
print_event:
	BRACKETOPEN print_contents BRACKETCLOSE
	|print_event print_event;

// Ορίζουμε τους κανόνες σύνταξης της εκτύπωσης.
printout:
	BRACKETOPEN PRINTOUT NAMES print_event BRACKETCLOSE
	|printout printout;

type:
	VARS
	|INTS;

// Ορίζουμε τους κανόνες σύνταξης της σύγκρισης.
comp:
	BRACKETOPEN EQUALS type type BRACKETCLOSE
	|BRACKETOPEN EQUALS type maths BRACKETCLOSE
	|BRACKETOPEN EQUALS maths type BRACKETCLOSE;

// Ορίζουμε τους κανόνες σύνταξης του test που περιέχει και σύγκριση μέσα.
test:
	BRACKETOPEN TEST comp BRACKETCLOSE;

// Ορίζουμε τους κανόνες σύνταξης του defrule που περιέχει NAMES στοιχεία γεγονόντων και test μέσα.
defrule:
	BRACKETOPEN DEFRULE NAMES NL events NL test NL ARROW NL printout BRACKETCLOSE;

// Ορίζουμε όλους τους τελεστές για μαθηματικές πράξεις.
math_ops:
	PLUSOP
	|MINUSOP
	|MULTOP
	|DIVOP;

// Oρίζουμε τα στοιχεία που μπορούν να υπάρχουν μέσα σε μία μαθηματική πράξη.
math_elements:
	VARS
	|INTS
	|math_elements math_elements;

// Ορίζουμε τους κανόνες σύνταξης για τις μαθηματικές πράξεις που περιέχει και σύγκριση μέσα.
maths:
	BRACKETOPEN math_ops math_elements math_elements BRACKETCLOSE;

// Ορίζουμε τους κανόνες σύνταξης για την read.
read:
	BRACKETOPEN READ BRACKETCLOSE;

// Ορίζουμε τους κανόνες σύνταξης για την bind που περιέχει την read και την maths.
bind:
	BRACKETOPEN BIND VARS read BRACKETCLOSE
	|BRACKETOPEN BIND VARS INTS BRACKETCLOSE
	|BRACKETOPEN BIND VARS maths BRACKETCLOSE;
	
%%

int yyerror(char *s)
{
}

int main(int argc, char **argv)
{
	// Εάν υπάρχει αρχείο για διάβασμα το δέχεται σαν είσοδος το πρόγραμμα αλλίως διαβάζει είσοδος απο τον χρήστη.
	if(argc == 2)
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;
	
	// Η yyparse επεξεργάζεται την έισοδο και άν συμβαδίζει με τους κανόνες που έχουμε ορίσει.
	yyparse();
	printf("\nFinished parsing.\n\n");
	
	// Εκτύπωση των στοιχείων που θέλουμε να δούμε (σωστές/λάθος λέξεις, σωστές/λάθος εκφράσεις).
	printf("Lines: %d\n", line);
	printf("Correct words: %d\n", correct_words);
	printf("Correct syntax: %d\n", correct_syntax);
	printf("Wrong words: %d\n", wrong_words);
	printf("Wrong syntax: %d\n", wrong_syntax);
	
	return 0;
}


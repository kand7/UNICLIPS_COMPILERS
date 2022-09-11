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
  int warnings = 0;
  extern char *yytext;
  extern FILE *yyin;
  int yylex();
  int flag =0 ;
%}

%token ARROW BRACKETOPEN BRACKETCLOSE DEFFACTS DEFRULE TEST BIND READ PRINTOUT EQUALS PLUSOP MINUSOP MULTOP DIVOP INTS FLOATS NAMES VARS STRINGS NL TOKEN_ERROR end_of_file

%%
// Ορίζουμε όλους τους συντακτικούς κανόνες τις uni-clips που θέλουμε να αναγνωρίζει ο αναλυτής μας.
// Κάθε φορά που εμφανίζεται σωστός κανόνας θα εμφανίζεται η γραμμή στην οποία βρίσκεται, το είδος και η ένδειξη "correct".
// Tο ίδιο θα συμβαίνει για τα σφάλματα αλλα θα εμφανίζεται ένα ερωτηματικό και η ένδειξη "error".
program:
    program NL
	|program events NL   {printf("\nLine: %d type: event. Correct.\n", line); correct_syntax++;}
	|program warning_events NL {printf("\nLine: %d type: event. Warning: Missing a bracket or extra brackets.\n", line); warnings++;}
	|program deffacts NL {printf("\nLine: %d type: deffacts. Correct.\n", line); correct_syntax++;}
	|program warning_deffacts NL {printf("\nLine: %d type: deffacts. Warning: Missing a bracket or extra brackets.\n", line); warnings++;}
	|program defrule NL  {printf("\nLine: %d type: defrule. Correct.\n", line); correct_syntax++;}
	|program warning_defrule NL {printf("\nLine: %d type: defrule. Warning: Missing a bracket or extra brackets.\n", line); warnings++;}
	|program maths NL    {printf("\nLine: %d type: maths. Correct.\n", line); correct_syntax++;}
	|program warning_maths NL {printf("\nLine: %d type: maths. Warning: 2 math operators (the first operator will be read and the second will be ignored).\n", line); warnings++;}
	|program comp NL     {printf("\nLine: %d type: compare. Correct.\n", line); correct_syntax++;}
	|program warning_comp NL {printf("\nLine: %d type: compare. Warning: Missing a bracket or extra brackets.\n", line); warnings++;}
	|program test NL     {printf("\nLine: %d type: test. Correct.\n", line); correct_syntax++;}
	|program warning_test NL {printf("\nLine: %d type: test. Warning: Missing a bracket or extra brackets.\n", line); warnings++;}
	|program bind NL     {printf("\nLine: %d type: bind. Correct.\n", line); correct_syntax++;}
	|program printout NL {printf("\nLine: %d type: printout. Correct.\n", line); correct_syntax++;}
	|program warning_printout NL {printf("\nLine: %d type: printout. Warning: Missing a bracket or extra brackets.\n", line); warnings++;}
	|program error NL    {printf("\nLine: %d type: ?. Error.\n", line);yyerrok; wrong_syntax++ , flag++;}
	|;

// Παρακατω ορίζουμε κάποιους κανόνες που θα μας βοηθήσουν να "χτίσουμε" τους συντακτικούς μας κανόνες.

// Ορίζουμε την αντιστοιχία των NAMES INTS ΚΑΙ VARS από τον λεκτικό αναλυτή μας.
//names:
	//NAMES {$$ = "NAMES";};

//ints:
	//INTS {$$ = "INTS";};

//vars:
	//VARS {$$ = "VARS";};

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
// Σε περίπτωση που ο χρήστης εισάγει παραπάνω παρενθέσεις ή ξεχάσει μία, πραγματοποιούνται τα events με warning.
warning_events:
    elements BRACKETCLOSE
	|BRACKETOPEN elements
	|BRACKETOPEN events
	|events BRACKETCLOSE
	|BRACKETOPEN events BRACKETCLOSE
	|warning_events warning_events;

// Μας επιτρέπει να έχουμε πολλά στοιχεία γεγονόντων το ένα κάτω από το άλλο και θα μας χρειαστεί για το deffacts
deffacts_events:
	BRACKETOPEN elements BRACKETCLOSE
	|deffacts_events deffacts_events
	|deffacts_events NL deffacts_events;

// Ορίζουμε τους συντακτικούς κανόνες για το deffacts.
deffacts:
	BRACKETOPEN DEFFACTS NAMES NL deffacts_events BRACKETCLOSE;
// Σε περίπτωση που ο χρήστης εισάγει παραπάνω παρενθέσεις ή ξεχάσει μία, πραγματοποιούνται τα deffacts με warning.
warning_deffacts:
    BRACKETOPEN DEFFACTS NAMES NL deffacts_events
    |DEFFACTS NAMES NL deffacts_events BRACKETCLOSE
    |deffacts BRACKETCLOSE
    |BRACKETOPEN deffacts
    |BRACKETOPEN deffacts BRACKETCLOSE;

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
// Σε περίπτωση που ο χρήστης εισάγει παραπάνω παρενθέσεις ή ξεχάσει μία, πραγματοποιούνται τα printout με warning.
warning_printout:
    PRINTOUT NAMES print_event BRACKETCLOSE
    |BRACKETOPEN PRINTOUT NAMES print_event
    |BRACKETOPEN printout
    |printout BRACKETCLOSE
    |BRACKETOPEN printout BRACKETCLOSE;

type:
	VARS
	|INTS;

// Ορίζουμε τους κανόνες σύνταξης της σύγκρισης.
comp:
	BRACKETOPEN EQUALS type type BRACKETCLOSE
	|BRACKETOPEN EQUALS type maths BRACKETCLOSE
	|BRACKETOPEN EQUALS maths type BRACKETCLOSE;
// Σε περίπτωση που ο χρήστης εισάγει παραπάνω παρενθέσεις, πραγματοποιούνται τα compare με warning.
warning_comp:
    BRACKETOPEN comp
    |comp BRACKETCLOSE
    |BRACKETOPEN comp BRACKETCLOSE;

// Ορίζουμε τους κανόνες σύνταξης του test που περιέχει και σύγκριση μέσα.
test:
	BRACKETOPEN TEST comp BRACKETCLOSE;
// Σε περίπτωση που ο χρήστης εισάγει παραπάνω παρενθέσεις ή ξεχάσει μία, πραγματοποιούνται τα test με warning.
warning_test:
    TEST comp BRACKETCLOSE
    |BRACKETOPEN TEST comp
    |BRACKETOPEN test
    |test BRACKETCLOSE
    |BRACKETOPEN test BRACKETCLOSE;

// Ορίζουμε τους κανόνες σύνταξης του defrule που περιέχει NAMES στοιχεία γεγονόντων και test μέσα.
defrule:
	BRACKETOPEN DEFRULE NAMES NL events NL test NL ARROW NL printout BRACKETCLOSE;
// Σε περίπτωση που ο χρήστης εισάγει παραπάνω παρενθέσεις ή ξεχάσει μία, πραγματοποιούνται τα defrule με warning.
warning_defrule:
    DEFRULE NAMES NL events NL test NL ARROW NL printout BRACKETCLOSE
    |BRACKETOPEN DEFRULE NAMES NL events NL test NL ARROW NL printout
    |BRACKETOPEN defrule
    |defrule BRACKETCLOSE
    |BRACKETOPEN defrule BRACKETCLOSE;

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
// Σε περίπτωση που ο χρήστης εισάγει δύο τελεστές διαβάζεται σωστά η πράξη θεωρώντας ότι εκτελείται η πράξη του πρώτου τελεστή.
warning_maths:
    BRACKETOPEN math_ops math_ops math_elements math_elements BRACKETCLOSE;

// Ορίζουμε τους κανόνες σύνταξης για την read.
read:
	BRACKETOPEN READ BRACKETCLOSE;


// Ορίζουμε τους κανόνες σύνταξης για την bind που περιέχει την read και την maths.
bind:
	BRACKETOPEN BIND VARS read BRACKETCLOSE
	|BRACKETOPEN BIND VARS INTS BRACKETCLOSE
	|BRACKETOPEN BIND VARS maths BRACKETCLOSE;
	
%%

int main(int argc, char **argv)
{
	// Εάν υπάρχει αρχείο για διάβασμα το δέχεται σαν είσοδος το πρόγραμμα αλλίως διαβάζει είσοδος απο τον χρήστη.
	if(argc == 2)
		yyin = fopen(argv[1], "r");
	else
		yyin = stdin;
	
	// Η yyparse επεξεργάζεται την έισοδο και άν συμβαδίζει με τους κανόνες που έχουμε ορίσει.
	int parse = yyparse();
	
	// Εκτύπωση των στοιχείων που θέλουμε να δούμε (σωστές/λάθος λέξεις, σωστές/λάθος εκφράσεις).
	
	printf("\nLines: %d\n", line);
	printf("Correct words: %d\n", correct_words);
	printf("Correct syntax: %d\n", correct_syntax);
	if (warnings > 0)
	{
	    printf("Warnings: %d\n", warnings);
	}
	printf("Wrong words: %d\n", wrong_words);
    printf("Wrong syntax: %d\n", wrong_syntax);
	
	if (parse == 0 && flag == 0)
	{	
		printf("\nFinished parsing.\n");
 	}
 	else
 	{
		printf("\nFailed parsing.\n");
	}
	
	return 0;
}


/* Onoma arxeiou:       simple-flex-code.l
   Perigrafh:           Ypodeigma gia anaptyksh lektikou analyth me xrhsh tou ergaleiou Flex
   Syggrafeas:          Ergasthrio Metaglwttistwn, Tmhma Mhxanikwn Plhroforikhs kai Ypologistwn,
                        Panepisthmio Dytikhs Attikhs
   Sxolia:              To paron programma ylopoiei (me th xrhsh flex) enan aplo lektiko analyth
			pou anagnwrizei kena (space kai tab) kai akeraious (dekadikou systhmatos
			mono!) gia th glwssa Uni-CLIPS enw diaxeirizetai tous eidikous xarakthres
			neas grammhs '\n' (new line) kai 'EOF' (end of file). Yparxoun anafores
			gia thn anagnwrish metablhtwn, me ton pragmatiko kwdika na exei antikatastathei
			apo to lektiko FILL ME wste na symplhrwthei apo esas. Proairetika o lektikos
			analyths dexetai orismata arxeiwn gia eisodo kai eksodo.
   Odhgies ekteleshs:   Dinete "make" xwris ta eisagwgika ston trexonta katalogo. Enallaktika:
			flex -o simple-flex-code.c simple-flex-code.l
                        gcc -o simple-flex-code simple-flex-code.c
                        ./simple-flex-code
*/

/* H anagnwsh periorizetai se ena mono arxeio kai termatizei sto prwto EOF */
%option noyywrap


/* Kwdikas C gia orismo twn apaitoumenwn header files kai twn metablhtwn.
   Otidhpote anamesa sta %{ kai %} metaferetai autousio sto arxeio C pou
   tha dhmiourghsei to Flex. */

%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Header file pou periexei lista me ola ta tokens */
#include "token.h"

/* Orismos metrhth trexousas grammhs */
int line = 1;
// Μετρητές για κάθε είδος στοιχείου.
int ifloats = 0 ,iints = 0 ,inames = 0 ,ivars = 0 ,istrings = 0 ,icoms = 0 ,iun = 0;

%}


/* Onomata kai antistoixoi orismoi (ypo morfh kanonikhs ekfrashs).
   Meta apo auto, mporei na ginei xrhsh twn onomatwn (aristera) anti twn,
   synhthws idiaiterws makroskelwn kai dysnohtwn, kanonikwn ekfrasewn */
/*
    INTS: Ακέραιοι αριθμοί.
    FLOATS: Αριθμοί κινητής υποδιαστολής.
    NAMES: Ονόματα ορισμών και στοιχείων γεγονότων.
    VARS: Μεταβλητές.
    STRINGS: Συμβολοσειρές (ή Λεκτικά κυριολεκτικά).
    COMS: Σχόλια.
    BREAKS: Διαχωριστές.
    UN: Μη έγκυρα στοιχεία.
*/
DELIMITER   [ \t]+
INTS        [\s \t]*(0|[+-]?[1-9]+[0-9]*)[\s \t]*
FLOATS		[\s \t]*[-+]?(0|[1-9]+[0-9]*)([.][0-9]+([eE][+-](0|[1-9]+[0-9]*))?|[eE][+-]?(0|[1-9]+[0-9]*))[\s \t]*
NAMES 		[\s \t]*[a-zA-Z]+((-|_)*[0-9]*[a-zA-Z]*)*[\s \t]*
VARS		[\s \t]*\?([0-9]*[a-zA-Z]*)+[\s \t]*
STRINGS 	[\s \t]*\"(\\[\\\"n]|[^\"\\\n])*\"[\s \t]*
COMS		;.*\n
BREAKS		[\s]+
UN		    ^.*
	
/* Gia kathe pattern (aristera) pou tairiazei ekteleitai o antistoixos
   kwdikas mesa sta agkistra. H entolh return epitrepei thn epistrofh
   mias arithmhtikhs timhs mesw ths synarthshs yylex() */

%%
{INTS}      	{return INTS;}
{FLOATS}	    {return FLOATS;}
{NAMES}		    {return NAMES;}
{VARS}		    {return VARS;}
{STRINGS}	    {return STRINGS;}
{UN}		    {return UN;}
{COMS}		    {line++;}
\n		        {line++;}
<<EOF>>		    {printf("\nCheck out.txt file!\n");
                 printf("\nResults:  %d Ints , %d Floats , %d Names , %d Vars , %d Strings , %d Unknows\n",iints ,ifloats ,inames ,ivars ,istrings ,iun);
		         exit(0);}

%%

/* Pinakas me ola ta tokens se antistoixia me tous orismous sto token.h */
char *tname[9] = { "DELIMITER" ,"INTS" ,"FLOATS" ,"NAMES" ,"VARS" ,"STRINGS" ,"COMS" ,"BREAKS","UN"};


/* H synarthsh main: O kwdikas autos tha topotheththei autousios sto
   programma C pou tha dhmiourghsei to Flex kai tha apotelesei to arxiko
   shmeio ekteleshs ths efarmoghs tou lektikou analyth. */

int main(int argc, char **argv){
        int token;

        /* Ginetai o elegxos twn orismatwn ths grammhs entolwn. Ean ta
           orismata einai 3, to programma diabazei apo to arxeio tou 2ou
           orismatos kai grafei sto arxeio tou 3ou. Ean ta orismata einai
           2 diabazei apo to arxeio tou 2ou kai grafei sthn othonh.
           Ypenthymizetai oti to 1o orisma (argv[0]) sth C einai to onoma
           tou idiou tou ektelesimou arxeiou. */

        if(argc == 3){
                if(!(yyin = fopen(argv[1], "r"))) {
                        fprintf(stderr, "Cannot read file: %s\n", argv[1]);
                        return 1;
                }
                if(!(yyout = fopen(argv[2], "w"))) {
                        fprintf(stderr, "Cannot create file: %s\n", argv[2]);
                        return 1;
                }
        }
        else if(argc == 2){
                if(!(yyin = fopen(argv[1], "r"))) {
                        fprintf(stderr, "Cannot read file: %s\n", argv[1]);
                        return 1;
                }
        }

        /* H synarthsh yylex diabazei xarakthres apo thn eisodo kai prospathei
           na angnwrisei tokens. Ta tokens pou anagnwrizei einai auta pou exoun
           oristei sto paron arxeio, anamesa sta %% kai %%. An o kwdikas pou
           antistoixei se kapoio pattern periexei thn entolh 'return TIMH', h
           yylex() epistrefei thn timh auth h opoia kai apothhkeyetai sth
           metablhth token. */

        while( (token=yylex()) >= 0){
                /* Gia kathe token pou anagnwristhke, ektypwnetai h grammh pou auto
                   brethhke kathws kai to onoma tou mazi me thn timh tou. */
                // Οι τιμές εμφανίζονται μέσα σε "@" ώστε να καταλάβουμε τι ακριβώς διάβασε
                // ο κώδικας flex που γράψαμε.
                fprintf(yyout, "Line=%d\t\tToken=%s\t\tValue=@%s@\n" ,line ,tname[token-1] ,yytext);
                
                /*Αύξηση των μετρητών αναλόγως με το είδος του στοιχείου που εντοπίστηκε.*/
               		if(strcmp(tname[token-1],"INTS") == 0)
               			iints++;
               		else if(strcmp(tname[token-1],"FLOATS") == 0)
               			ifloats++;
               		else if(strcmp(tname[token-1],"NAMES") == 0)
               			inames++;
               		else if(strcmp(tname[token-1],"VARS") == 0)
               			ivars++;
               		else if(strcmp(tname[token-1],"STRINGS") == 0)
               			istrings++;
               		else if(strcmp(tname[token-1],"UN") == 0)
               			iun++;
             
                         
        }
        return 0;
}


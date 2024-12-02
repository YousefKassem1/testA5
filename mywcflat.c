/*--------------------------------------------------------------------*/
/* mywcflat.c                                                         */
/* Author: Nick and Yousef                                            */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void)
{
    readLoop:
    if ((iChar = getchar()) == EOF) goto endreadLoop;  /* Read a character from stdin*/
    lCharCount++;

    /* Check if character is whitespace */
    if (!isspace(iChar)) goto handleNonWhitespace;
    if (!iInWord) goto endif1;
    lWordCount++;
    iInWord = FALSE;
    endif1:
    goto check_newline;

    handleNonWhitespace:
    // If character is not whitespace and we are not already in a word, start a new word
    if (!iInWord) iInWord = TRUE;
    goto check_newline;

check_newline:
    if (iChar != '\n') goto endif2;
    lLineCount++;
    endif2:
    goto readLoop;

    endreadLoop:
    /* reached when the final word if EOF is reached while in a word */
    if (!iInWord) goto endif3;
    lWordCount++;
    endif3:

    /*Print the counts*/
    printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
    return 0;
}


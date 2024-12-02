//----------------------------------------------------------------------
// mywc.s
// Author: Nick and Yousef

//----------------------------------------------------------------------
    .section .rodata
//----------------------------------------------------------------------
    .section .data

// static long lLineCount = 0;
lLineCount:
    .quad 0

// static long lWordCount = 0;
lWordCount:
    .quad 0

// static long lCharCount = 0;
lCharCount:
    .quad 0

// static int iChar;
iChar:
    .skip 4

// static int iInWord = FALSE;
iInWord:
    .word 0

printFormat:
    .asciz "%7ld %7ld %7ld\n"

//----------------------------------------------------------------------
    .section .bss
//----------------------------------------------------------------------
    .section .text

    // Write to stdout counts of how many lines, words, and characters
    //  are in stdin. A word is a sequence of non-whitespace characters.
    // Whitespace is defined by the isspace() function. Return 0.

    .equ    MAIN_STACK_BYTECOUNT, 16
    .equ    EOF, #-1
    .equ    TRUE, #0
    .global main

main:
    // Prolog
    sub     sp, sp, MAIN_STACK_BYTECOUNT
    str     x30, [sp]

readLoop:
    // if ((iChar = getchar()) == EOF) goto endreadLoop;
    bl      getchar
    adr     x1, iChar
    strb    w0, [x1] // store char returned in w0 to iChar
    ldrb    w1, [x1] // load char into w1
    cmp     w1, EOF
    beq     endreadLoop

    // lCharCount++;
    ldr     x2, lCharCount
    mov     w2, #1
    add     x3, x2, w2 // lCharCount++ is in x3
    adr     x2, lCharCount
    str     x3, [x2] // store number in x3 to lCharCount's address

    // if (!isspace(iChar)) goto else1;
    ldrb    x0, [x1] // store char in x0 as parameter
    bl      isspace // w0 contains 0 or TRUE if is space
    mov     x3, TRUE
    cmp     w0, x3
    bne     else1

    // if (!iInWord) goto endif1;
    ldr     x4, iInWord
    cmp     x3, x4 // x3 contains TRUE
    bne     endif1

    // lWordCount++;
    ldr     x2, lWordCount
    add     x3, x2, w2 // w2 contains 1, result is in x3
    adr     x2, lCharCount
    str     x3, [x2] // store number in x3 to lWordCount's address

    // iInWord = FALSE;
    adr     x2, iInWord
    mov     x3, #0 // FALSE
    str     x3, [x2]

endif1:

else1:
    // if (iInWord) goto endif2;
    ldr     x3, iInWord
    mov     x4, TRUE
    cmp     x3, x4
    beq     endif2

    // iInWord = TRUE;
    adr     x3, iInWord
    str     x4, [x3] // x4 contains TRUE

endif2:
    // if (iChar != '\n') goto endif3;
    strb w0, #10 // newline literal
    cmp w1, w0 // char is in w1
    beq endif3

    // lLineCount++;
    ldr     x2, lLineCount
    add     x3, x2, w2 // w2 contains 1, result is in x3
    adr     x2, lLineCount
    str     x3, [x2] // store number in x3 to lLineCount's address

endif3:
    b readLoop

endreadLoop:
    // if (!iInWord) goto endif4;
    ldr     x3, iInWord
    mov     x4, TRUE
    cmp     x3, x4
    bne     endif4

    // lWordCount++;
    ldr     x2, lWordCount
    add     x3, x2, w2 // w2 contains 1, result is in x3
    adr     x2, lWordCount
    str     x3, [x2] // store number in x3 to lWordCount's address

endif4:
    // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
    adr     x0, printFormat
    ldr     x1, lLineCount
    ldr     x2, lWordCount
    ldr     x3, lCharCount
    bl      printf

    // Epilog and return 0
    mov     w0, #0
    ldr     x30, [sp]
    add     sp, sp, MAIN_STACK_BYTECOUNT
    ret

    .size   main, (. - main)









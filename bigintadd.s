    /*--------------------------------------------------------------------*/
    /* Define Sections and Constants                                      */
    /*--------------------------------------------------------------------*/

    /* Read-only data section for constants and offsets */
    .section .rodata

    /* Define constants */
    .equ    FALSE, 0
    .equ    TRUE, 1
    .equ    ULONG_SIZE, 8              /* Size of unsigned long */
    .equ    MAX_DIGITS, 256            /* Adjust as per bigintprivate.h */
    .equ    MAX_DIGITS_SIZE, MAX_DIGITS * ULONG_SIZE

    /* Define structure field offsets */
    .equ    LLENGTH, 0                 /* Offset of lLength in struct BigInt */
    .equ    AULDIGITS, 8               /* Offset of aulDigits in struct BigInt */

    /* Define stack offsets for BigInt_add */
    .equ    OADDEND1, 16               /* Offset for oAddend1 */
    .equ    OADDEND2, 24               /* Offset for oAddend2 */
    .equ    OSUM, 32                   /* Offset for oSum */
    .equ    ULCARRY, 40                /* Offset for ulCarry */
    .equ    ULSUM, 48                  /* Offset for ulSum */
    .equ    LINDEX, 56                 /* Offset for lIndex */
    .equ    LSUMLENGTH, 64             /* Offset for lSumLength */
    .equ    TOTAL_FRAME_SIZE, 80       /* Total stack frame size for BigInt_add */

    /* Define stack offsets for BigInt_larger */
    .equ    LLENGTH1, 16               /* Offset for lLength1 */
    .equ    LLENGTH2, 24               /* Offset for lLength2 */
    .equ    LLARGER, 32                /* Offset for lLarger */
    .equ    TOTAL_FRAME_SIZE_LARGER, 48/* Total stack frame size for BigInt_larger */

    /*--------------------------------------------------------------------*/
    /* Code Section                                                       */
    /*--------------------------------------------------------------------*/

    .section .text
    .align  2
    .global BigInt_add
    .type   BigInt_add, %function

    /*--------------------------------------------------------------------*/
    /* BigInt_add Function                                                */
    /*--------------------------------------------------------------------*/

BigInt_add:
    /* Function Prologue */
    stp     x29, x30, [sp, #-16]!         /* Save frame pointer and link register */
    mov     x29, sp                       /* Set frame pointer */
    sub     sp, sp, #(TOTAL_FRAME_SIZE - 16)  /* Allocate space for locals and params */

    /* Store parameters on the stack */
    str     x0, [x29, #OADDEND1]          /* oAddend1 */
    str     x1, [x29, #OADDEND2]          /* oAddend2 */
    str     x2, [x29, #OSUM]              /* oSum */

    /* Skip assert statements */

    /* Load oAddend1->lLength and oAddend2->lLength */
    ldr     x0, [x29, #OADDEND1]          /* x0 = oAddend1 */
    ldr     x1, [x29, #OADDEND2]          /* x1 = oAddend2 */
    ldr     x3, [x0, #LLENGTH]            /* x3 = oAddend1->lLength */
    ldr     x4, [x1, #LLENGTH]            /* x4 = oAddend2->lLength */

    /* Call BigInt_larger(x3, x4) */
    mov     x0, x3                        /* x0 = lLength1 */
    mov     x1, x4                        /* x1 = lLength2 */
    bl      BigInt_larger                 /* Result in x0 */

    /* Store lSumLength */
    str     x0, [x29, #LSUMLENGTH]

    /* Check if oSum->lLength > lSumLength */
    ldr     x0, [x29, #OSUM]              /* x0 = oSum */
    ldr     x1, [x29, #LSUMLENGTH]        /* x1 = lSumLength */
    ldr     x2, [x0, #LLENGTH]            /* x2 = oSum->lLength */
    cmp     x2, x1
    ble     skip_memset                   /* If oSum->lLength <= lSumLength, skip memset */

    /* Prepare arguments for memset */
    add     x0, x0, #AULDIGITS            /* x0 = oSum->aulDigits */
    mov     x1, #0                        /* x1 = value 0 */
    ldr     x2, =MAX_DIGITS_SIZE          /* x2 = size in bytes */
    bl      memset                        /* Call memset */

skip_memset:

    /* Initialize ulCarry = 0 */
    mov     x0, #0
    str     x0, [x29, #ULCARRY]

    /* Initialize lIndex = 0 */
    mov     x0, #0
    str     x0, [x29, #LINDEX]

/* Loop Start */
loop_start:
    /* Load lIndex and lSumLength */
    ldr     x0, [x29, #LINDEX]            /* x0 = lIndex */
    ldr     x1, [x29, #LSUMLENGTH]        /* x1 = lSumLength */
    cmp     x0, x1
    bge     loop_end                      /* Exit loop if lIndex >= lSumLength */

    /* ulSum = ulCarry */
    ldr     x2, [x29, #ULCARRY]           /* x2 = ulCarry */
    str     x2, [x29, #ULSUM]             /* ulSum = ulCarry */

    /* ulCarry = 0 */
    mov     x2, #0
    str     x2, [x29, #ULCARRY]

    /* ulSum += oAddend1->aulDigits[lIndex] */
    ldr     x3, [x29, #OADDEND1]          /* x3 = oAddend1 */
    ldr     x4, [x29, #LINDEX]            /* x4 = lIndex */
    add     x5, x3, #AULDIGITS            /* x5 = oAddend1->aulDigits */
    lsl     x6, x4, #3                    /* x6 = lIndex * 8 */
    add     x5, x5, x6                    /* x5 = &oAddend1->aulDigits[lIndex] */
    ldr     x7, [x5]                      /* x7 = oAddend1->aulDigits[lIndex] */

    ldr     x2, [x29, #ULSUM]             /* x2 = ulSum */
    adds    x2, x2, x7                    /* ulSum += oAddend1->aulDigits[lIndex], set flags */
    bcs     carry_set1                    /* If carry set, branch */
    b       no_carry1

carry_set1:
    mov     x8, #1
    str     x8, [x29, #ULCARRY]           /* ulCarry = 1 */

no_carry1:
    str     x2, [x29, #ULSUM]             /* Store updated ulSum */

    /* ulSum += oAddend2->aulDigits[lIndex] */
    ldr     x3, [x29, #OADDEND2]          /* x3 = oAddend2 */
    ldr     x4, [x29, #LINDEX]            /* x4 = lIndex */
    add     x5, x3, #AULDIGITS            /* x5 = oAddend2->aulDigits */
    lsl     x6, x4, #3                    /* x6 = lIndex * 8 */
    add     x5, x5, x6                    /* x5 = &oAddend2->aulDigits[lIndex] */
    ldr     x7, [x5]                      /* x7 = oAddend2->aulDigits[lIndex] */

    ldr     x2, [x29, #ULSUM]             /* x2 = ulSum */
    adds    x2, x2, x7                    /* ulSum += oAddend2->aulDigits[lIndex], set flags */
    bcs     carry_set2                    /* If carry set, branch */
    b       no_carry2

carry_set2:
    mov     x8, #1
    str     x8, [x29, #ULCARRY]           /* ulCarry = 1 */

no_carry2:
    str     x2, [x29, #ULSUM]             /* Store updated ulSum */

    /* oSum->aulDigits[lIndex] = ulSum */
    ldr     x3, [x29, #OSUM]              /* x3 = oSum */
    ldr     x4, [x29, #LINDEX]            /* x4 = lIndex */
    add     x5, x3, #AULDIGITS            /* x5 = oSum->aulDigits */
    lsl     x6, x4, #3                    /* x6 = lIndex * 8 */
    add     x5, x5, x6                    /* x5 = &oSum->aulDigits[lIndex] */
    ldr     x2, [x29, #ULSUM]             /* x2 = ulSum */
    str     x2, [x5]                      /* oSum->aulDigits[lIndex] = ulSum */

    /* lIndex++ */
    ldr     x0, [x29, #LINDEX]
    add     x0, x0, #1
    str     x0, [x29, #LINDEX]

    b       loop_start

loop_end:

    /* Check for carry out */
    ldr     x0, [x29, #ULCARRY]
    cmp     x0, #1
    bne     skip_carry_out

    /* If ulCarry == 1 */
    ldr     x1, [x29, #LSUMLENGTH]        /* x1 = lSumLength */
    mov     x2, #MAX_DIGITS
    cmp     x1, x2
    beq     return_false                  /* If lSumLength == MAX_DIGITS, return FALSE */

    /* oSum->aulDigits[lSumLength] = 1 */
    ldr     x3, [x29, #OSUM]              /* x3 = oSum */
    add     x4, x3, #AULDIGITS            /* x4 = oSum->aulDigits */
    lsl     x5, x1, #3                    /* x5 = lSumLength * 8 */
    add     x5, x4, x5                    /* x5 = &oSum->aulDigits[lSumLength] */
    mov     x6, #1
    str     x6, [x5]                      /* oSum->aulDigits[lSumLength] = 1 */

    /* lSumLength++ */
    add     x1, x1, #1
    str     x1, [x29, #LSUMLENGTH]

skip_carry_out:

    /* oSum->lLength = lSumLength */
    ldr     x0, [x29, #OSUM]              /* x0 = oSum */
    ldr     x1, [x29, #LSUMLENGTH]        /* x1 = lSumLength */
    str     x1, [x0, #LLENGTH]            /* oSum->lLength = lSumLength */

    /* Return TRUE */
    mov     x0, #TRUE
    b       function_end

return_false:
    /* Return FALSE */
    mov     x0, #FALSE

function_end:
    /* Function Epilogue */
    add     sp, x29, #0                   /* Restore sp */
    ldp     x29, x30, [sp], #16           /* Restore x29 and x30 */
    ret

    /*--------------------------------------------------------------------*/
    /* BigInt_larger Function                                             */
    /*--------------------------------------------------------------------*/

    .align  2
    .global BigInt_larger
    .type   BigInt_larger, %function

BigInt_larger:
    /* Function Prologue */
    stp     x29, x30, [sp, #-16]!         /* Save frame pointer and link register */
    mov     x29, sp                       /* Set frame pointer */
    sub     sp, sp, #(TOTAL_FRAME_SIZE_LARGER - 16)  /* Allocate space */

    /* Store parameters on the stack */
    str     x0, [x29, #LLENGTH1]          /* lLength1 */
    str     x1, [x29, #LLENGTH2]          /* lLength2 */

    /* Compare lLength1 and lLength2 */
    ldr     x0, [x29, #LLENGTH1]          /* x0 = lLength1 */
    ldr     x1, [x29, #LLENGTH2]          /* x1 = lLength2 */
    cmp     x0, x1
    ble     else_branch

    /* lLarger = lLength1 */
    str     x0, [x29, #LLARGER]
    b       end_if

else_branch:
    /* lLarger = lLength2 */
    str     x1, [x29, #LLARGER]

end_if:
    /* Return lLarger */
    ldr     x0, [x29, #LLARGER]

    /* Function Epilogue */
    add     sp, x29, #0                   /* Restore sp */
    ldp     x29, x30, [sp], #16           /* Restore x29 and x30 */
    ret

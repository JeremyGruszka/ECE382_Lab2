;-------------------------------------------------------------------------------
; Lab 2
; Jeremy Gruszka, 15 SEP 2014
;
; Encrypter -- Takes in a message, uses a key to encrpyt the message, then uses
;			   the same key to decrypt the message.
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section

message		.byte	0xf8,0xb7,0x46,0x8c,0xb2,0x46,0xdf,0xac,0x42,0xcb,0xba,0x03,0xc7,0xba,0x5a,0x8c,0xb3,0x46,0xc2,0xb8,0x57,0xc4,0xff,0x4a,0xdf,0xff,0x12,0x9a,0xff,0x41,0xc5,0xab,0x50,0x82,0xff,0x03,0xe5,0xab,0x03,0xc3,0xb1,0x4f,0xd5,0xff,0x40,0xc3,0xb1,0x57,0xcd,0xb6,0x4d,0xdf,0xff,0x4f,0xc9,0xab,0x57,0xc9,0xad,0x50,0x80,0xff,0x53,0xc9,0xad,0x4a,0xc3,0xbb,0x50,0x80,0xff,0x42,0xc2,0xbb,0x03,0xdf,0xaf,0x42,0xcf,0xba,0x50,0x8f

key:		.byte	0xac, 0xdf, 0x23		;key used for encryption/decryption

memLocation:.equ	0x0200					;constant for memory location in RAM

keyLength:	.equ	0x03					;length of key for B functionality

mesLength:	.equ	0x5E					;length of message

;-------------------------------------------------------------------------------

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

			mov.w	#message, R4            ;
            mov.w	#memLocation, R10		; load registers with necessary info for decryptMessage here
            mov.w	#key, R6				;
			mov.w	#keyLength, R7			;

            call    #decryptMessage

forever:    jmp     forever

;-------------------------------------------------------------------------------
; Subroutines
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;Subroutine Name: decryptMessage
;Author: Jeremy Gruszka
;Function: Decrypts a string of bytes and stores the result in memory.  Accepts
;           the address of the encrypted message, address of the key, and address
;           of the decrypted message (pass-by-reference).  Accepts the length of
;           the message by value.  Uses the decryptCharacter subroutine to decrypt
;           each byte of the message.  Stores theresults to the decrypted message
;           location.
;Inputs:	R4 (message), R11 (message length counter), R6 (key), R7 (key length)
;Outputs:	Decrypted Message in RAM starting at location 0x0200
;Registers destroyed:	None
;-------------------------------------------------------------------------------

decryptMessage:

			mov.w	#mesLength, R11		;counter for length of message
			mov.b	@R4+, R5			;moves next part of message into register
			mov.b	@R6+, R8			;moves next part of key into register
			call	#decryptCharacter
			mov.b	R5, 0(R10)			;stores decrypted message in memory
			inc.w	R10
			dec.w	R7
			jz		keyTracker			;resets the key if it reaches the end of the key
subReset
			dec.w	R11
			jnz		decryptMessage		;re-runs decrypt message as long as there is part of the message left

            ret

keyTracker
			mov.w	#key, R6
			mov.w	#keyLength, R7
			jmp		subReset

;-------------------------------------------------------------------------------
;Subroutine Name: decryptCharacter
;Author: Jeremy Gruszka
;Function: Decrypts a byte of data by XORing it with a key byte.  Returns the
;           decrypted byte in the same register the encrypted byte was passed in.
;           Expects both the encrypted data and key to be passed by value.
;Inputs:	R5 (character), R8 (key)
;Outputs:	R5 (decrypted character)
;Registers destroyed:	R5
;-------------------------------------------------------------------------------

decryptCharacter:

			xor		R8, R5				;decrypts character

            ret

;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect    .stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

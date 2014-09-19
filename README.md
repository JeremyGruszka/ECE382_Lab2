ECE382_Lab2
===========

##Lab2

Note - It says that I committed my main.asm at 1706 hours on Thursday.  I actually committed before COB yesterday, I had just forgotten to update the header for this program so I went in and changed my header.  That is why it says I committed my main.asm just now

####Objective

Encrypter -- Takes in an encrypted message and a key, then uses the same key to decrypt the message.

####Flow Chart and Pseudocode

![alt text](https://raw.githubusercontent.com/JeremyGruszka/ECE382_Lab2/master/flowchart.jpg "Flowchart")

![alt text](https://raw.githubusercontent.com/JeremyGruszka/ECE382_Lab2/master/pseudocode.jpg "Pseudocode")

####Code

```
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section

message		  .byte	0xf8,0xb7,0x46,0x8c,0xb2,0x46,0xdf,0xac,0x42,0xcb,0xba,0x03,0xc7,0xba,0x5a,0x8c,0xb3,0x46,0xc2,0xb8,0x57,0xc4,0xff,0x4a,0xdf,0xff,0x12,0x9a,0xff,0x41,0xc5,0xab,0x50,0x82,0xff,0x03,0xe5,0xab,0x03,0xc3,0xb1,0x4f,0xd5,0xff,0x40,0xc3,0xb1,0x57,0xcd,0xb6,0x4d,0xdf,0xff,0x4f,0xc9,0xab,0x57,0xc9,0xad,0x50,0x80,0xff,0x53,0xc9,0xad,0x4a,0xc3,0xbb,0x50,0x80,0xff,0x42,0xc2,0xbb,0x03,0xdf,0xaf,0x42,0xcf,0xba,0x50,0x8f

key:		    .byte	0xac, 0xdf, 0x23		;key used for encryption/decryption

memLocation:.equ	0x0200					;constant for memory location in RAM

keyLength:	.equ	0x03					;length of key for B functionality

mesLength:	.equ	0x5E					;length of message

;-------------------------------------------------------------------------------

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

			      mov.w	#message, R4        ;
            mov.w	#memLocation, R10		; load registers with necessary info for decryptMessage here
            mov.w	#key, R6				    ;
			      mov.w	#keyLength, R7			;

            call    #decryptMessage

forever:    jmp     forever
```
This section of code contains the constants and the main section of the program.  message is the array holding the encrypted message.  key is the array holding the decryption key. The three .equ lines create constants so that magic numbers need not be used in the program.  The three first lines in the main loop set up storage of the hex equation and memory locations.  The main section of the code loads the message, key, key length, and memory starting point into registers for use by the program.

```
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
			mov.b	@R4+, R5			    ;moves next part of message into register
			mov.b	@R6+, R8		    	;moves next part of key into register
			call	#decryptCharacter
			mov.b	R5, 0(R10)			  ;stores decrypted message in memory
			inc.w	R10
			dec.w	R7
			jz		keyTracker		  	;resets the key if it reaches the end of the key
subReset
			dec.w	R11
			jnz		decryptMessage		;re-runs decrypt message as long as there is part of the message left

            ret

keyTracker
			mov.w	#key, R6
			mov.w	#keyLength, R7
			jmp		subReset
```
This section of contains the decryptMessage subroutine. I had to manually count the length of the encrypted message, and then made a for loop that decrypted the message until the message was fully decrypted.  This part of the code also contains the B functionality.  It essentially uses the key until the key is fully used, and then resets the key.  This allows any length

```
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
```
This final section of code contains the decrypt character subroutine.  
```

;-------------------------------------------------------------------------------
; Checks to see if the operation is an 44, and if so, adds a 00 to memory
;-------------------------------------------------------------------------------
checkClear
          cmp.b	#Clear, R7
          jnz	end	          ;operation is a 55, end program
          mov.b	#0x00, R9
          mov.b	R9, 0(R10)
          inc.w	R10
          mov.b	R8, R6
          jmp	main
```
This section of the program works with the Clear function of the calculator.  When a 0x44 is read by the program, it writes 0x00 to memory and starts the program over with the next part of the equation.  If not, this means a 0x55 is being read and the equation is at an end.  The clearing operation required a different approach to reseting the program and thus jumped back to main for reset.

```
;-------------------------------------------------------------------------------
; Resets the program after a non clearing operation
;-------------------------------------------------------------------------------
nonClearOp
          mov.b	R9, R6
          mov.b	@R5+, R7
          mov.b	@R5+, R8
          jmp	checkAdd
```
This section of code resets the program after non clearing operations.

####Debugging/Testing

I started the program by using the basic outline given in the handout for lab 1 help.  That gave me the basic idea of how I would write the program.  However, the handout had different functions than what we needed in this lab so I had to write those functions myself, as well as figure out how to get B functionality and reset the program depending on the type of operation being done.  

I didn't have too many problems with this program surprisingly.  I wrote the code I believed would work and it worked.  The hard part of the program for me was getting the B functionality.  I had to go through multiple iterations of writing and testing code to get it working.  

Unfortunately, due to time constraints, other homework, and my lack of creativity with this particular type of programming, I was not able to get the A functionality of the code working.

I ran the test cases given by the lab handout for the basic program and for the B functionality.  Each test produced the correct result, showing that my basic program worked and that my B functionality worked.

Documentation:  Class notes and handouts, Lab 1 handout, C2C Taylor Bodin's readme as a guideline

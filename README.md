ECE382_Lab2
===========

##Lab2

Note - It says that I committed my main.asm at 1706 hours on Thursday.  I actually committed before COB yesterday, I had just forgotten to update the header for this program so I went in and changed my header.  That is why it says I committed my main.asm just now

####Objective

Encrypter -- Takes in an encrypted message and a key, then uses the same key to decrypt the message.

According to the Lab 2 handout on the sharepoint, the objective is:

You'll practice your programming skills by writing some subroutines. You'll need to use both the call-by-value and call-by-reference techniques to pass arguments to your subroutines.


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

message		.byte	0xf8,0xb7,0x46,0x8c,0xb2,0x46,0xdf,0xac,0x42,0xcb,0xba,0x03,0xc7,0xba,0x5a,0x8c,0xb3,0x46,0xc2,0xb8,0x57,0xc4,0xff,0x4a,0xdf,0xff,0x12,0x9a,0xff,0x41,0xc5,0xab,0x50,0x82,0xff,0x03,0xe5,0xab,0x03,0xc3,0xb1,0x4f,0xd5,0xff,0x40,0xc3,0xb1,0x57,0xcd,0xb6,0x4d,0xdf,0xff,0x4f,0xc9,0xab,0x57,0xc9,0xad,0x50,0x80,0xff,0x53,0xc9,0xad,0x4a,0xc3,0xbb,0x50,0x80,0xff,0x42,0xc2,0xbb,0x03,0xdf,0xaf,0x42,0xcf,0xba,0x50,0x8f

key:		.byte	0xac, 0xdf, 0x23	;key used for encryption/decryption

memLocation:	.equ	0x0200			;constant for memory location in RAM

keyLength:	.equ	0x03			;length of key for B functionality

mesLength:	.equ	0x5E			;length of message

;-------------------------------------------------------------------------------

RESET       	mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     	mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

		mov.w	#message, R4        	;
            	mov.w	#memLocation, R10	; load registers with necessary info for decryptMessage here
            	mov.w	#key, R6		;
		mov.w	#keyLength, R7		;

            	call    #decryptMessage

forever:    	jmp     forever
```
This section of code contains the constants and the main section of the program.  message is the array holding the encrypted message.  key is the array holding the decryption key. The three .equ lines create constants so that magic numbers do not need to be used in the program.  The three first lines in the main loop set up storage of the hex equation and memory locations.  The main section of the code loads the message, key, key length, and memory starting point into registers for use by the program.

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
			mov.b	@R4+, R5		;moves next part of message into register
			mov.b	@R6+, R8		;moves next part of key into register
			call	#decryptCharacter
			mov.b	R5, 0(R10)		;stores decrypted message in memory
			inc.w	R10
			dec.w	R7
			jz	keyTracker		;resets the key if it reaches the end of the key
subReset
			dec.w	R11
			jnz	decryptMessage		;re-runs decrypt message as long as there is part of the message left

            		ret

keyTracker
			mov.w	#key, R6
			mov.w	#keyLength, R7
			jmp	subReset
```
This section of contains the decryptMessage subroutine. I had to manually count the length of the encrypted message, and then made a for loop that decrypted the message until the message was fully decrypted.  This part of the code also contains the B functionality.  It essentially uses the key until the key is fully used, and then resets the key.  This allows any length of key to be used for decrption.

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

			xor	R8, R5		;decrypts character

            		ret
```
This final section of code contains the decrypt character subroutine.  It takes in an individual byte and XORs it with the key which decrypts the byte.  It then sends it back to the decryptMessage subroutine for storage in RAM.


####Debugging/Testing

I started the program by using the basic outline given in the Lab 2 instructions on the sharepoint.  That gave me the basic idea of how I would write the program.  I had the basic outline and then had to fill in each portion to get the program functionality working.  

I wrote the program as I thought it should work and tried compiling.  I had a weird error at the XOR portion of the decrpytCharacter subroutine where it was saying something along the lines of the key register was not allowed in the subroutine.  After pulling out my hair for ahwile, I realized that I needed to change my key from a .equ to .byte in order to place it in ROM.  That was the only problem that I had with the required funcitonality.

My biggest problem with B functionality was finding an easy yet simple way to reset the key once the end of the key is reached.  I solved this by using jumps inside the decryptMessage subroutine to temporarily leave the subroutine and reset the key, then return to the same spot in the subroutine.

Unfortunately, due to time constraints, other homework, and my lack of creativity with this particular type of programming, I was not able to get the A functionality of the code working.

####Conclusions/Results

I ran the test cases given by the lab handout for the basic program and for the B functionality.  Each test produced the correct result, showing that my basic program worked and that my B functionality worked.

Here is a picture of my memory after running my program, showing that my required functionality works:
![alt text](https://raw.githubusercontent.com/JeremyGruszka/ECE382_Lab2/master/required_functionality.jpg "Required Functionality")

Here is a picture of my memory after running my program, showing that my B functionality works:
![alt text](https://raw.githubusercontent.com/JeremyGruszka/ECE382_Lab2/master/B_functionality.jpg "B Functionality")

Documentation:  Class notes and handouts, Lab 2 handout, My previous work and labs

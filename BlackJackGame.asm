;-------------------------------------------------------------------------------
; Name:              [Sailesh Ranjitkar]
; Course:            [CSC2025, X00], [Computer Arch/Assembly]
; Program Title:     BlackJack Game
; Date:              [12/06/2024]
;
; Description:
; This program simulates a complete game of Blackjack between a player and a dealer. 
; It initializes and shuffles a standard deck of 52 cards, deals two initial cards to both the player and the dealer, and manages the gameplay loop where the player can choose to "Hit" or "Stand." 
; The program dynamically handles card values, including adjusting the value of Aces to prevent busting, and enforces standard Blackjack rules for the dealer's actions. 
; It visually represents cards using ASCII art, tracks and updates the hands' values, determines the game outcome (win, loss, or push), and allows the player to play multiple rounds with options to continue or exit. 
;-------------------------------------------------------------------------------

INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data                                                 ; Start of the data segment
cardWidth	= 10                                     ; Define the width of a card as 10 units
blankcard  BYTE "|        |",0                        ; ASCII art for a blank card
cardline1  BYTE ".--------.",0                       ; ASCII art for the top line of a card
cardline2  BYTE "|",0                               ; ASCII art for the second line of a card
cardline6  BYTE        "|",0                        ; ASCII art for the sixth line of a card
cardline7  BYTE "`--------'",0                       ; ASCII art for the bottom line of a card

; ASCII art for hearts
cardline2a BYTE    "_  _  |",0                       ; Second line for hearts
cardline3a BYTE "| ( \/ ) |",0                     ; Third line for hearts
cardline4a BYTE "|  \  /  |",0                     ; Fourth line for hearts
cardline5a BYTE "|   \/ ",0                        ; Fifth line for hearts

; ASCII art for diamonds
cardline2b BYTE    " /\   |",0                       ; Second line for diamonds
cardline3b BYTE "|  /  \  |",0                     ; Third line for diamonds
cardline4b BYTE "|  \  /  |",0                     ; Fourth line for diamonds
cardline5b BYTE "|   \/ ",0                        ; Fifth line for diamonds

; ASCII art for clubs
cardline2c BYTE    " _    |",0                       ; Second line for clubs
cardline3c BYTE "|  ( )   |",0                     ; Third line for clubs
cardline4c BYTE "| (_X_)  |",0                     ; Fourth line for clubs
cardline5c BYTE "|   Y  ",0                        ; Fifth line for clubs

; ASCII art for spades
cardline2d BYTE    " .    |",0                       ; Second line for spades
cardline3d BYTE "|  / \   |",0                     ; Third line for spades
cardline4d BYTE "| (_,_)  |",0                     ; Fourth line for spades
cardline5d BYTE "|   I  ",0                        ; Fifth line for spades

CARD STRUCT                                          ; Define a structure for a card
	FACE		WORD 00                               ; Card face (A, 2, ..., K)
	SUIT		BYTE 0                                ; Card suit
	Value	BYTE 0                                ; Value of the card
CARD ENDS                                            ; End of the CARD structure

cardDeck	CARD <' A',1,11>,	<' A',2,11>,	<' A',3,11>,	<' A',4,11> ; Initialize the deck with Aces of all suits
			CARD	<' 2',1,2>,	<' 2',2,2>,	<' 2',3,2>,	<' 2',4,2> ; Initialize the deck with 2s of all suits
			CARD	<' 3',1,3>,	<' 3',2,3>,	<' 3',3,3>,	<' 3',4,3> ; Initialize the deck with 3s of all suits
			CARD	<' 4',1,4>,	<' 4',2,4>,	<' 4',3,4>,	<' 4',4,4> ; Initialize the deck with 4s of all suits
			CARD	<' 5',1,5>,	<' 5',2,5>,	<' 5',3,5>,	<' 5',4,5> ; Initialize the deck with 5s of all suits
			CARD	<' 6',1,6>,	<' 6',2,6>,	<' 6',3,6>,	<' 6',4,6> ; Initialize the deck with 6s of all suits
			CARD	<' 7',1,7>,	<' 7',2,7>,	<' 7',3,7>,	<' 7',4,7> ; Initialize the deck with 7s of all suits
			CARD	<' 8',1,8>,	<' 8',2,8>,	<' 8',3,8>,	<' 8',4,8> ; Initialize the deck with 8s of all suits
			CARD	<' 9',1,9>,	<' 9',2,9>,	<' 9',3,9>,	<' 9',4,9> ; Initialize the deck with 9s of all suits
			CARD	<'10',1,10>,	<'10',2,10>,	<'10',3,10>,	<'10',4,10> ; Initialize the deck with 10s of all suits
			CARD	<' J',1,10>,	<' J',2,10>,	<' J',3,10>,	<' J',4,10> ; Initialize the deck with Jacks of all suits
			CARD	<' Q',1,10>,	<' Q',2,10>,	<' Q',3,10>,	<' Q',4,10> ; Initialize the deck with Queens of all suits
			CARD	<' K',1,10>,	<' K',2,10>,	<' K',3,10>,	<' K',4,10> ; Initialize the deck with Kings of all suits

deckAsNum BYTE 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ; Array representing card indices for shuffling
		BYTE 26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51 ; Continue initializing deckAsNum with card indices

dealerHand	CARD 10 DUP(<>)                          ; Initialize the dealer's hand with 10 empty cards
playerHand	CARD 10 DUP(<>)                          ; Initialize the player's hand with 10 empty cards
dealerValue BYTE 0                                  ; Initialize the dealer's hand value to 0
playerValue BYTE 0                                  ; Initialize the player's hand value to 0
player BYTE 1                                       ; Boolean to indicate it's the player's turn
dealer BYTE 0                                       ; Boolean to indicate it's the dealer's turn
dealerHandMsg BYTE "Dealer's Hand: ",0             ; Message to display the dealer's hand
playerHandMsg BYTE "Player's Hand: ",0             ; Message to display the player's hand
invalidInputMsg BYTE "Invalid input. Please enter 0 or 1.",0 ; Message for invalid input
pushMsg BYTE "Push! It's a tie.",0                  ; Message for a tie game

deckSize = 52                                       ; Define the size of the deck as 52 cards
numberOfDecks BYTE ?                                ; Variable to store the number of decks used in the game

playerTurn BYTE 1                                   ; Boolean to check if it's the player's turn
                                                    ; If true, dealer's first card is hidden

movePrompt BYTE "0 - Stand, 1 - Hit",0             ; Prompt message for player's action
playerAction DWORD ?                                ; Variable to store the player's action

welcomeMessage BYTE "Welcome to a game of BlackJack!", 0 ; Welcome message displayed at game start
goodbyeMsg BYTE "Thank you for playing. Good Bye!",0        ; Goodbye message displayed when exiting

playerWinsMsg	BYTE "Player Wins!",0               ; Message displayed when the player wins
dealerWinsMsg	BYTE "Dealer Wins!",0               ; Message displayed when the dealer wins
bustMsg		BYTE "BUST! Dealer Wins!",0           ; Message displayed when the player busts
blackJackMsg	BYTE "BlackJack!",0                 ; Message displayed when a Blackjack is achieved
dealerToPush	BYTE "Dealer will now try to push.",0 ; Message displayed when dealer tries to push
playAgainPrompt BYTE "Play again? (0 - Yes, 1 - No)",0 ; Prompt to ask if the player wants to play again

Hit PROTO, turn:BYTE                                ; Prototype for the Hit procedure
PrintHand PROTO, turn:BYTE                          ; Prototype for the PrintHand procedure
AceCalculation PROTO, turn:BYTE                        ; Prototype for the AceCalculation procedure		
rowsToSkip BYTE ?										; if its the player, start 
firstCard DWORD ?										; save first random number for swapping
secondCard DWORD ?										; second random number

.code

;---------------------------------------------------------------------------------------------------
; Procedure: main
; Description:
;    Serves as the entry point for the Blackjack game. Initializes game settings, shuffles the deck,
;    deals initial cards to both dealer and player, manages the game loop (handling player and dealer turns),
;    and handles game termination and replay prompts.
;
; Inputs:
;    None
;
; Outputs:
;    None (Manages game flow and controls other procedures)
;
; Memory Usage:
;    Utilizes global variables such as deckAsNum, dealerHand, playerHand, playerValue, dealerValue,
;    playerTurn, and various message strings.
;
; Registers Used:
;    EBX - Points to dealerHand
;    EDX - Points to playerHand and various message addresses
;    ESI - Points to deckAsNum for tracking shuffled deck
;    EAX - General-purpose register for various operations
;    ECX - Loop counters
;    DH, DL - Screen coordinates for Gotoxy
;
;---------------------------------------------------------------------------------------------------

main PROC
		call Randomize                                   ; Seed the random number generator

Game:                                               ; Game loop label

	mov playerTurn, 1                                 ; Set playerTurn to true indicating it's the player's turn
	call Clrscr                                       ; Clear the screen

	mov ebx, OFFSET dealerHand                        ; Load the address of dealerHand into EBX
	mov edx, OFFSET playerHand                        ; Load the address of playerHand into EDX
	mov esi, OFFSET deckAsNum                          ; Load the address of deckAsNum into ESI
	call Shuffle                                      ; Shuffle the deck
	call DealCards                                    ; Deal initial cards to dealer and player

	.IF(dealerValue == 21) || (playerValue == 21)      ; Check if either dealer or player has Blackjack
		jmp Game                                        ; If Blackjack, start a new game
	.ENDIF

	call movePhase                                   ; Enter the phase where player decides to hit or stand

	Invoke PrintHand, player                          ; Print the player's hand
	Invoke PrintHand, dealer                          ; Print the dealer's hand
	call ClearHands                                   ; Clear both hands for the next round

	; Ask player to play again or quit
	mov dh, 10                                        ; Set vertical position for the prompt
	mov dl, 20                                        ; Set horizontal position for the prompt
	call Gotoxy                                       ; Move cursor to (20,10)
	mov edx, OFFSET playAgainPrompt                   ; Load the address of playAgainPrompt
	call WriteString                                  ; Display the play again prompt
	mov dh, 11                                        ; Set vertical position for input
	mov dl, 20                                        ; Set horizontal position for input
	call Gotoxy                                       ; Move cursor to (20,11)
	call ReadDec                                      ; Read the player's input
	call Crlf                                         ; Move the cursor to the next line
	.IF (eax == 0)                                    ; If player chooses to play again
		jmp Game                                        ; Jump to the Game label to start a new game
	.ELSE                                            ; If player chooses to quit
		jmp quitout                                     ; Jump to the quitout label to exit
	.ENDIF

quitout:                                           ; Label for quitting the game
	call Clrscr                                      ; Clear the screen
	mov dh, 10                                       ; Set vertical position for goodbye message
	mov dl, 20                                       ; Set horizontal position for goodbye message
	call Gotoxy                                      ; Move cursor to (20,10)
	mov edx, OFFSET goodbyeMsg                       ; Load the address of goodbyeMsg
	call WriteString                                 ; Display the goodbye message
	mov dh, 11                                       ; Set vertical position for delay
	mov dl, 20                                       ; Set horizontal position for delay
	call Gotoxy                                      ; Move cursor to (20,11)
	mov eax, 1000                                    ; Set delay duration
	call Delay                                       ; Delay to allow player to read the message

	exit                                             ; Exit the program
main ENDP                                          ; End of the main procedure

;---------------------------------------------------------------------------------------------------
; Procedure: movePhase
; Description:
;    Handles the player's decision-making phase. Prompts the player to choose between "Hit" or "Stand",
;    processes the input, updates the player's hand accordingly, and checks for Blackjack or bust conditions.
;
; Inputs:
;    turn:BYTE - Indicates whether it's the player's turn (1) or dealer's turn (0)
;
; Outputs:
;    Updates playerValue and potentially alters playerTurn based on actions
;
; Memory Usage:
;    Uses global variables like playerValue, dealerValue, playerAction, and message strings for prompts
;
; Registers Used:
;    EAX - Temporarily holds user input and other operations
;    EDX - Points to message strings for display
;    EBX - General-purpose register
;    ECX - Loop counters
;    ESI - Points to deckAsNum during card hits
;    DH, DL - Screen coordinates for Gotoxy
;
;---------------------------------------------------------------------------------------------------
movePhase PROC                                     ; Begin movePhase procedure
	push eax                                       ; Save EAX register on the stack
	push edx                                       ; Save EDX register on the stack

checkagain:                                       ; Label to recheck conditions after an action
	Invoke PrintHand, player                        ; Display the player's current hand
	Invoke PrintHand, dealer                        ; Display the dealer's current hand
	.IF (playerValue == 21)                          ; If player has Blackjack
		mov dh, 10                                 ; Set vertical position for message
		mov dl, 20                                 ; Set horizontal position for message
		call Gotoxy                                ; Move cursor to (20,10)
		mov edx, OFFSET dealerToPush                ; Load the address of dealerToPush message
		call WriteString                            ; Display the dealer will try to push
		mov dh, 11                                 ; Set vertical position for next message
		mov dl, 20                                 ; Set horizontal position for next message
		call Gotoxy                                ; Move cursor to (20,11)
		call WaitMsg                               ; Wait for user input to continue
		call dealerTurn                            ; Proceed to the dealer's turn
		jmp endMove                                ; Jump to the end of movePhase
	.ELSEIF (playerValue > 21)                      ; If player busts
		INVOKE AceCalculation, 1                        ; Check if player has an Ace to adjust
		.IF(playerValue <= 21)                        ; If adjusting Ace prevents bust
			jmp checkagain                            ; Allow player to take another action
		.ENDIF
		mov dh, 10                                 ; Set vertical position for bust message
		mov dl, 20                                 ; Set horizontal position for bust message
		call Gotoxy                                ; Move cursor to (20,10)
		mov edx, OFFSET bustMsg                      ; Load the address of bustMsg
		call WriteString                            ; Display the bust message
		mov dh, 11                                 ; Set vertical position for next message
		mov dl, 20                                 ; Set horizontal position for next message
		call Gotoxy                                ; Move cursor to (20,11)
		call WaitMsg                               ; Wait for user input to continue
		mov playerTurn, 0                           ; Set playerTurn to false to show all dealer cards
		jmp endMove                                ; Jump to the end of movePhase
	.ENDIF

	mov dh, 10                                      ; Set vertical position for move prompt
	mov dl, 20                                      ; Set horizontal position for move prompt
	call Gotoxy                                     ; Move cursor to (20,10)
	mov edx, OFFSET movePrompt                       ; Load the address of movePrompt
	call WriteString                                 ; Display the move prompt
	mov dh, 11                                      ; Set vertical position for player input
	mov dl, 20                                      ; Set horizontal position for player input
	call Gotoxy                                     ; Move cursor to (20,11)
	call ReadDec                                    ; Read the player's action (0 or 1)
	mov playerAction, eax                           ; Store the player's action in playerAction
	call Clrscr                                     ; Clear the screen

	.IF (eax == 0)                                    ; If player chooses to Stand
		call dealerTurn                                 ; Proceed to the dealer's turn
	.ELSEIF (eax == 1)                                ; If player chooses to Hit
		pop edx                                       ; Restore EDX register from the stack
		Invoke Hit, player                              ; Add a card to the player's hand
		push edx                                      ; Save EDX register back on the stack
		jmp checkAgain                                ; Jump back to checkagain to evaluate the new hand
	.ELSE                                            ; If player input is invalid
		mov dh, 10                                 ; Set vertical position for invalid input message
		mov dl, 20                                 ; Set horizontal position for invalid input message
		call Gotoxy                                ; Move cursor to (20,10)
		mov edx, OFFSET invalidInputMsg                ; Load the address of invalidInputMsg
		call WriteString                            ; Display the invalid input message
		call WaitMsg                               ; Wait for user input to continue
		jmp checkagain                              ; Jump back to checkagain to prompt again
	.ENDIF
endMove:                                           ; Label marking the end of movePhase
	pop edx                                        ; Restore EDX register from the stack
	pop eax                                        ; Restore EAX register from the stack
	ret                                            ; Return from movePhase procedure
movePhase ENDP                                     ; End of movePhase procedure

;---------------------------------------------------------------------------------------------------
; Procedure: dealerTurn
; Description:
;    Manages the dealer's actions after the player stands. The dealer will continue to "Hit" until
;    reaching a hand value of at least 17 or until the dealer's hand value beats the player's.
;    Handles bust conditions and determines the game outcome.
;
; Inputs:
;    None (Uses global variables to determine dealer actions)
;
; Outputs:
;    Updates dealerValue and determines the winner or if it's a push
;
; Memory Usage:
;    Utilizes dealerHand, dealerValue, playerValue, and message strings for outcome display
;
; Registers Used:
;    EDX - Points to playerValue for comparison
;    EBX - Points to dealerHand
;    EAX - General-purpose register for operations
;    ECX - Loop counters
;    DH, DL - Screen coordinates for Gotoxy
;
;---------------------------------------------------------------------------------------------------
dealerTurn PROC                                    ; Begin dealerTurn procedure
	push edx                                       ; Save EDX register on the stack
	mov playerTurn, 0                               ; Set playerTurn to false to reveal dealer's cards
	mov dl, playerValue                             ; Move playerValue into DL for comparison

dealerturnagain:                                  ; Label for dealer's turn loop
	.WHILE (dealerValue < 17) || (dealerValue < dl) ; Continue hitting if dealer's value is less than 17 or less than player's value
		INVOKE Hit, dealer                              ; Add a card to the dealer's hand
		Invoke PrintHand, player                        ; Display the player's hand
		Invoke PrintHand, dealer                        ; Display the dealer's hand
		call WaitMsg                                   ; Wait for user input to continue
	.ENDW

	.IF (dealerValue > 21)                            ; If dealer busts
		INVOKE AceCalculation, 0                            ; Check if dealer has an Ace to adjust
		.IF (dealerValue <= 21)                           ; If adjusting Ace prevents bust
			jmp dealerturnagain                           ; Continue the dealer's turn
		.ENDIF
	.ENDIF

	call Clrscr                                      ; Clear the screen
	Invoke PrintHand, player                        ; Display the player's hand
	Invoke PrintHand, dealer                        ; Display the dealer's hand

	mov dh, 10                                       ; Set vertical position for outcome message
	mov dl, 20                                       ; Set horizontal position for outcome message
	call Gotoxy                                      ; Move cursor to (20,10)
	mov dl, playerValue                             ; Move playerValue into DL for comparison
	.IF (dealerValue == dl)                           ; If dealer and player have the same value
		mov edx, OFFSET pushMsg                          ; Load the address of pushMsg
		call WriteString                                ; Display the push message
		mov dh, 11                                       ; Set vertical position for next message
		mov dl, 20                                       ; Set horizontal position for next message
		call Gotoxy                                      ; Move cursor to (20,11)
		call WaitMsg                                     ; Wait for user input to continue
	.ELSEIF (dealerValue <= 21)                       ; If dealer's value is valid and beats the player
		mov edx, OFFSET dealerWinsMsg                      ; Load the address of dealerWinsMsg
		call WriteString                                ; Display the dealer wins message
		mov dh, 11                                       ; Set vertical position for next message
		mov dl, 20                                       ; Set horizontal position for next message
		call Gotoxy                                      ; Move cursor to (20,11)
		call WaitMsg                                     ; Wait for user input to continue
	.ELSE                                             ; If dealer busts, player wins
		mov edx, OFFSET playerWinsMsg                      ; Load the address of playerWinsMsg
		call WriteString                                ; Display the player wins message
		mov dh, 11                                       ; Set vertical position for next message
		mov dl, 20                                       ; Set horizontal position for next message
		call Gotoxy                                      ; Move cursor to (20,11)
		call WaitMsg                                     ; Wait for user input to continue
	.ENDIF

	pop edx                                        ; Restore EDX register from the stack
	ret                                            ; Return from dealerTurn procedure
dealerTurn ENDP                                     ; End of dealerTurn procedure


;---------------------------------------------------------------------------------------------------
; Procedure: Hit
; Description:
;    Adds a card to either the player's or dealer's hand based on the 'turn' parameter.
;    Updates the corresponding hand's value by adding the value of the drawn card.
;
; Inputs:
;    turn:BYTE - Specifies whose hand to add the card to (1 for player, 0 for dealer)
;
; Outputs:
;    Modifies playerHand or dealerHand by adding a new card
;    Updates playerValue or dealerValue accordingly
;
; Memory Usage:
;    Accesses cardDeck and deckAsNum to draw a card
;    Updates playerHand or dealerHand structures
;
; Registers Used:
;    EDI - Points to cardDeck for accessing card details
;    EDX - Points to the current hand (playerHand or dealerHand)
;    ESI - Points to deckAsNum for tracking drawn cards
;    EBX - Temporarily holds suit information
;    EAX - Temporarily holds card numbers and values
;
;---------------------------------------------------------------------------------------------------
Hit PROC, turn:BYTE                               ; Begin Hit procedure with turn parameter
	push edi                                       ; Save EDI register on the stack
	mov edi, OFFSET cardDeck                         ; Load the address of cardDeck into EDI

	.IF (turn == 1)                                   ; If it's the player's turn
		mov eax, 0                                 ; Clear EAX register
		mov al, BYTE PTR [esi]                       ; Load the next card index from deckAsNum into AL

		add edi, eax                                 ; Calculate the address of the card in cardDeck
		add edi, eax                                 ; Multiply index by 4 (size of CARD structure)
		add edi, eax                                 ; Continue address calculation
		add edi, eax                                 ; Finalize address calculation for CARD structure

		mov ax, (CARD PTR[edi]).Face                  ; Load the card's face into AX
		mov (CARD PTR[edx]).Face, ax                  ; Store the face in the player's hand
		mov al, (CARD PTR[edi]).Suit                  ; Load the card's suit into AL
		mov (CARD PTR[edx]).Suit, al                  ; Store the suit in the player's hand
		mov al, (CARD PTR[edi]).Value                 ; Load the card's value into AL
		mov (CARD PTR[edx]).Value, al                 ; Store the value in the player's hand
		add playerValue, al                           ; Add the card's value to playerValue
		add edx, TYPE CARD                            ; Move to the next card position in playerHand
		inc esi                                       ; Increment the deckAsNum index
	.ELSE                                             ; If it's the dealer's turn
		mov eax, 0                                 ; Clear EAX register
		mov al, BYTE PTR [esi]                       ; Load the next card index from deckAsNum into AL

		add edi, eax                                 ; Calculate the address of the card in cardDeck
		add edi, eax                                 ; Multiply index by 4 (size of CARD structure)
		add edi, eax                                 ; Continue address calculation
		add edi, eax                                 ; Finalize address calculation for CARD structure

		mov ax, (CARD PTR[edi]).Face                  ; Load the card's face into AX
		mov (CARD PTR[ebx]).Face, ax                  ; Store the face in the dealer's hand
		mov al, (CARD PTR[edi]).Suit                  ; Load the card's suit into AL
		mov (CARD PTR[ebx]).Suit, al                  ; Store the suit in the dealer's hand
		mov al, (CARD PTR[edi]).Value                 ; Load the card's value into AL
		mov (CARD PTR[ebx]).Value, al                 ; Store the value in the dealer's hand
		add dealerValue, al                           ; Add the card's value to dealerValue
		add ebx, TYPE CARD                            ; Move to the next card position in dealerHand
		inc esi                                       ; Increment the deckAsNum index
	.ENDIF

	pop edi                                        ; Restore EDI register from the stack
	ret                                            ; Return from Hit procedure
Hit ENDP                                           ; End of Hit procedure

;---------------------------------------------------------------------------------------------------
; Procedure: ClearHands
; Description:
;    Resets both the dealer's and player's hands by clearing all cards and resetting their values.
;    Prepares the game state for a new round.
;
; Inputs:
;    None
;
; Outputs:
;    Sets all cards in dealerHand and playerHand to zero
;    Resets dealerValue and playerValue to zero
;
; Memory Usage:
;    Modifies dealerHand and playerHand structures
;
; Registers Used:
;    EBX - Points to dealerHand
;    EDX - Points to playerHand
;    ECX - Loop counter for clearing cards
;    EAX - Temporary storage for zeroing values
;
;---------------------------------------------------------------------------------------------------
ClearHands PROC                                   ; Begin ClearHands procedure
	push eax                                       ; Save EAX register on the stack
	push ecx                                       ; Save ECX register on the stack
	mov ebx, OFFSET dealerHand                        ; Load the address of dealerHand into EBX
	mov edx, OFFSET playerHand                        ; Load the address of playerHand into EDX
	mov ecx, 10                                     ; Set loop counter to 10 for each card in hand

clear:                                            ; Loop label for clearing hands
	mov (CARD PTR[ebx]).Face,	ax                    ; Reset the face of the current dealer card to 0
	mov (CARD PTR[ebx]).Suit,	al                    ; Reset the suit of the current dealer card to 0
	mov (CARD PTR[ebx]).Value,	al                   ; Reset the value of the current dealer card to 0
	mov (CARD PTR[edx]).Face,	ax                    ; Reset the face of the current player card to 0
	mov (CARD PTR[edx]).Suit,	al                    ; Reset the suit of the current player card to 0
	mov (CARD PTR[edx]).Value,	al                   ; Reset the value of the current player card to 0
	add ebx, TYPE CARD                              ; Move to the next dealer card
	add edx, TYPE CARD                              ; Move to the next player card
	LOOP clear                                      ; Decrement ECX and loop if not zero

	pop ecx                                        ; Restore ECX register from the stack
	pop eax                                        ; Restore EAX register from the stack
	ret                                            ; Return from ClearHands procedure
ClearHands ENDP                                    ; End of ClearHands procedure

;---------------------------------------------------------------------------------------------------
; Procedure: DealCards
; Description:
;    Deals the initial two cards each to the dealer and the player. Updates the respective hand values.
;    Checks for immediate Blackjack conditions and handles them accordingly.
;
; Inputs:
;    None
;
; Outputs:
;    Populates dealerHand and playerHand with initial cards
;    Updates dealerValue and playerValue based on dealt cards
;    May trigger immediate game outcomes like Blackjack or Push
;
; Memory Usage:
;    Accesses deckAsNum and cardDeck to draw and assign initial cards
;    Utilizes global variables for hand structures and message displays
;
; Registers Used:
;    EAX - Temporarily holds card numbers and values
;    EDI - Points to cardDeck for accessing card details
;    EDX - Points to playerHand and dealerHand
;    EBX - Points to dealerHand during card assignment
;    ECX - Loop counter for dealing two cards each
;    ESI - Points to deckAsNum for tracking drawn cards
;
;---------------------------------------------------------------------------------------------------
DealCards PROC                                    ; Begin DealCards procedure
	push eax                                       ; Save EAX register on the stack
	push edi                                       ; Save EDI register on the stack
	push ecx                                       ; Save ECX register on the stack

	mov edi, OFFSET cardDeck                         ; Load the address of cardDeck into EDI

	mov dealerValue, 0                              ; Initialize dealerValue to 0
	mov playerValue, 0                              ; Initialize playerValue to 0

	; esi points to deckAsNum
	; ebx points to dealerHand
	; edx points to playerHand

	mov ecx, 2                                     ; Set loop counter to 2 for dealing two cards each

dealcardsloop:                                   ; Loop label for dealing cards
	mov eax, 0                                     ; Clear EAX register
	mov al, BYTE PTR [esi]                           ; Load the next card index from deckAsNum into AL

	mov edi, OFFSET cardDeck                         ; Reload the address of cardDeck into EDI
	add edi, eax                                   ; Calculate the address of the card in cardDeck
	add edi, eax                                   ; Multiply index by 4 (size of CARD structure)
	add edi, eax                                   ; Continue address calculation
	add edi, eax                                   ; Finalize address calculation for CARD structure

	mov ax, (CARD PTR[edi]).Face                      ; Load the card's face into AX
	mov (CARD PTR[edx]).Face, ax                      ; Store the face in the player's hand
	mov al, (CARD PTR[edi]).Suit                      ; Load the card's suit into AL
	mov (CARD PTR[edx]).Suit, al                      ; Store the suit in the player's hand
	mov al, (CARD PTR[edi]).Value                     ; Load the card's value into AL
	mov (CARD PTR[edx]).Value, al                     ; Store the value in the player's hand
	add playerValue, al                               ; Add the card's value to playerValue
	add edx, TYPE CARD                                ; Move to the next player card
	inc esi                                       ; Increment the deckAsNum index

	mov eax, 0                                     ; Clear EAX register
	mov al, BYTE PTR [esi]                           ; Load the next card index from deckAsNum into AL

	mov edi, OFFSET cardDeck                         ; Reload the address of cardDeck into EDI
	add edi, eax                                   ; Calculate the address of the card in cardDeck
	add edi, eax                                   ; Multiply index by 4 (size of CARD structure)
	add edi, eax                                   ; Continue address calculation
	add edi, eax                                   ; Finalize address calculation for CARD structure

	mov ax, (CARD PTR[edi]).Face                      ; Load the card's face into AX
	mov (CARD PTR[ebx]).Face, ax                      ; Store the face in the dealer's hand
	mov al, (CARD PTR[edi]).Suit                      ; Load the card's suit into AL
	mov (CARD PTR[ebx]).Suit, al                      ; Store the suit in the dealer's hand
	mov al, (CARD PTR[edi]).Value                     ; Load the card's value into AL
	mov (CARD PTR[ebx]).Value, al                     ; Store the value in the dealer's hand
	add dealerValue, al                               ; Add the card's value to dealerValue
	add ebx, TYPE CARD                                ; Move to the next dealer card
	inc esi                                       ; Increment the deckAsNum index

	LOOP dealcardsloop                             ; Decrement ECX and loop if not zero

	.IF (dealerValue > 21)                            ; If dealer's value exceeds 21
		INVOKE AceCalculation, 0                            ; Check and adjust dealer's Ace if possible
	.ELSEIF (playerValue > 21)                        ; If player's value exceeds 21
		INVOKE AceCalculation, 1                            ; Check and adjust player's Ace if possible
	.ELSEIF (dealerValue == 21) && (playerValue == 21)    ; If both have Blackjack
		push edx                                       ; Save EDX register on the stack
		mov dh, 10                                 ; Set vertical position for push message
		mov dl, 20                                 ; Set horizontal position for push message
		call Gotoxy                                ; Move cursor to (20,10)
		mov edx, OFFSET pushMsg                          ; Load the address of pushMsg
		call WriteString                            ; Display the push message
		mov dh, 11                                 ; Set vertical position for next message
		mov dl, 20                                 ; Set horizontal position for next message
		call Gotoxy                                ; Move cursor to (20,11)
		call WaitMsg                               ; Wait for user input to continue
		pop edx                                        ; Restore EDX register from the stack
		jmp endDeal                                 ; Jump to the end of DealCards
	.ELSEIF (dealerValue == 21)                       ; If dealer has Blackjack
		push edx                                       ; Save EDX register on the stack
		mov dh, 10                                 ; Set vertical position for Blackjack message
		mov dl, 20                                 ; Set horizontal position for Blackjack message
		call Gotoxy                                ; Move cursor to (20,10)
		mov edx, OFFSET blackJackMsg                     ; Load the address of blackJackMsg
		call WriteString                            ; Display the Blackjack message
		mov dh, 11                                 ; Set vertical position for dealer wins message
		mov dl, 20                                 ; Set horizontal position for dealer wins message
		call Gotoxy                                ; Move cursor to (20,11)
		mov edx, OFFSET dealerWinsMsg                    ; Load the address of dealerWinsMsg
		call WriteString                            ; Display the dealer wins message
		call WaitMsg                               ; Wait for user input to continue
		pop edx                                        ; Restore EDX register from the stack
		jmp endDeal                                 ; Jump to the end of DealCards
	.ELSEIF (playerValue == 21)                       ; If player has Blackjack
		push edx                                       ; Save EDX register on the stack
		mov dh, 10                                 ; Set vertical position for Blackjack message
		mov dl, 20                                 ; Set horizontal position for Blackjack message
		call Gotoxy                                ; Move cursor to (20,10)
		mov edx, OFFSET blackJackMsg                     ; Load the address of blackJackMsg
		call WriteString                            ; Display the Blackjack message
		mov dh, 11                                 ; Set vertical position for player wins message
		mov dl, 20                                 ; Set horizontal position for player wins message
		call Gotoxy                                ; Move cursor to (20,11)
		mov edx, OFFSET playerWinsMsg                    ; Load the address of playerWinsMsg
		call WriteString                            ; Display the player wins message
		call WaitMsg                               ; Wait for user input to continue
		pop edx                                        ; Restore EDX register from the stack
		jmp endDeal                                 ; Jump to the end of DealCards
	.ENDIF
endDeal:                                           ; Label marking the end of DealCards
	pop ecx                                        ; Restore ECX register from the stack
	pop edi                                        ; Restore EDI register from the stack
	pop eax                                        ; Restore EAX register from the stack
	ret                                            ; Return from DealCards procedure
DealCards ENDP                                     ; End of DealCards procedure

;---------------------------------------------------------------------------------------------------
; Procedure: Shuffle
; Description:
;    Randomizes the order of the deck by shuffling the deckAsNum array. Implements a swap-based
;    shuffling algorithm to ensure randomness of card distribution.
;
; Inputs:
;    None
;
; Outputs:
;    Shuffles the deckAsNum array to randomize card order
;
; Memory Usage:
;    Modifies deckAsNum array in the data segment
;    Uses temporary variables firstCard and secondCard for swapping
;
; Registers Used:
;    EAX - Holds random indices for swapping
;    EBX - Temporarily holds second card value during swap
;    ECX - Loop counter for shuffle iterations (200)
;    ESI - Points to deckAsNum for accessing and swapping cards
;
;---------------------------------------------------------------------------------------------------
Shuffle PROC                                       ; Begin Shuffle procedure
	push eax                                       ; Save EAX register on the stack
	push ebx                                       ; Save EBX register on the stack
	push ecx                                       ; Save ECX register on the stack
	push esi                                       ; Save ESI register on the stack

	mov ecx, 200                                    ; Set loop counter to 200 for thorough shuffling

shufflecards:                                      ; Loop label for shuffling cards
	mov esi, OFFSET deckAsNum                        ; Load the address of deckAsNum into ESI
	mov eax, 52                                     ; Set the upper limit for random range
	call RandomRange                                ; Generate a random index between 0 and 51
	mov firstCard, eax                               ; Store the first random index in firstCard

	call Random32                                   ; Generate a random number
	mov eax, 52                                     ; Set the upper limit for random range
	call RandomRange                                ; Generate a second random index between 0 and 51
	mov secondCard, eax                              ; Store the second random index in secondCard

	mov eax, 0                                     ; Clear EAX register for swapping
	mov ebx, 0                                     ; Clear EBX register for swapping
	add esi, firstCard                               ; Move ESI to the first random card index
	mov al, [esi]                                   ; Load the value of the first card into AL
	mov esi, OFFSET deckAsNum                        ; Reload the address of deckAsNum into ESI
	add esi, secondCard                              ; Move ESI to the second random card index
	mov bl, [esi]                                   ; Load the value of the second card into BL
	mov [esi], al                                   ; Swap the first card value into the second card's position
	mov esi, OFFSET deckAsNum                        ; Reload the address of deckAsNum into ESI
	add esi, firstCard                               ; Move ESI back to the first random card index
	mov [esi], bl                                   ; Swap the second card value into the first card's position
	LOOP shufflecards                               ; Decrement ECX and loop if not zero

	pop esi                                        ; Restore ESI register from the stack
	pop ecx                                        ; Restore ECX register from the stack
	pop ebx                                        ; Restore EBX register from the stack
	pop eax                                        ; Restore EAX register from the stack
	ret                                            ; Return from Shuffle procedure
Shuffle ENDP                                        ; End of Shuffle procedure

;---------------------------------------------------------------------------------------------------
; Procedure: PrintHand
; Description:
;    Displays the current hand (player or dealer) on the screen using ASCII art for each card.
;    Handles the visual representation of different suits and hides the dealer's first card
;    during the player's turn.
;
; Inputs:
;    turn:BYTE - Specifies which hand to print (1 for player, 0 for dealer)
;
; Outputs:
;    Renders the ASCII art of the specified hand on the screen
;
; Memory Usage:
;    Accesses playerHand or dealerHand structures
;    Utilizes ASCII art byte arrays for different card suits
;
; Registers Used:
;    EAX - General-purpose register for operations
;    EBX - Holds suit information for determining ASCII art
;    ECX - Loop counter for iterating through cards
;    EDX - Points to message strings and controls screen output
;    ESI - Points to the appropriate hand (playerHand or dealerHand)
;    DH, DL - Screen coordinates for Gotoxy
;
;---------------------------------------------------------------------------------------------------
PrintHand PROC, turn:BYTE                          ; Begin PrintHand procedure with turn parameter
	push eax                                       ; Save EAX register on the stack
	push ebx                                       ; Save EBX register on the stack
	push ecx                                       ; Save ECX register on the stack
	push edx                                       ; Save EDX register on the stack
	push esi                                       ; Save ESI register on the stack

	mov ecx, 10                                     ; Set loop counter to 10 for up to 10 cards

	mov ebx, 0                                     ; Clear EBX register
	mov eax, 0                                     ; Clear EAX register
	mov dl,0                                       ; Initialize DL for cursor position
	mov dh,0                                       ; Initialize DH for cursor position
	call Gotoxy                                    ; Move cursor to (0,0)
	mov edx, OFFSET dealerHandMsg                     ; Load the address of dealerHandMsg
	call WriteString                                ; Display the dealer's hand message
	.IF (playerTurn != 1)                             ; If it's not the player's turn
		mov al, dealerValue                             ; Load dealerValue into AL
		call WriteDec                                  ; Display the dealer's value
	.ENDIF
	mov dl,0                                       ; Reset DL for cursor position
	mov dh,18                                      ; Set vertical position for playerHand
	call Gotoxy                                    ; Move cursor to (0,18)
	mov edx, OFFSET playerHandMsg                     ; Load the address of playerHandMsg
	call WriteString                                ; Display the player's hand message
	mov al, playerValue                             ; Load playerValue into AL
	call WriteDec                                  ; Display the player's value
	mov dl,0                                       ; Reset DL for cursor position

	.IF (turn == 1)                                    ; If printing the player's hand
		mov rowsToSkip, 19                              ; Start printing at row 19
		mov esi, OFFSET playerHand                       ; Point ESI to playerHand
	.ELSEIF (playerTurn == 1)                          ; If it's still the player's turn
		mov rowsToSkip, 1                               ; Start printing at row 1 for dealer
		mov esi, OFFSET dealerHand                       ; Point ESI to dealerHand
		jmp coverCard                                  ; Jump to coverCard to hide dealer's first card
	.ELSE                                             ; If it's not the player's turn and not printing player's hand
		mov rowsToSkip, 1                               ; Start printing at row 1
		mov esi, OFFSET dealerHand                       ; Point ESI to dealerHand
	.ENDIF

testcard:                                         ; Label to test and print each card
	mov ebx, 0                                     ; Clear EBX register
	mov dh, rowsToSkip                               ; Set vertical position for the card
	mov bl, (CARD PTR[esi]).Suit                      ; Load the suit of the current card into BL
	.IF		(bl == 0)                                   ; If suit is 0, no more cards to print
		jmp retout                                     ; Jump to retout to finish printing
	.ELSEIF	(bl == 1)                                   ; If suit is 1 (Hearts)
		jmp heart                                      ; Jump to the heart printing section
	.ELSEIF	(bl == 2)                                   ; If suit is 2 (Diamonds)
		jmp diamond                                    ; Jump to the diamond printing section
	.ELSEIF	(bl == 3)                                   ; If suit is 3 (Clubs)
		jmp clubs                                       ; Jump to the clubs printing section
	.ELSEIF	(bl == 4)                                   ; If suit is 4 (Spades)
		jmp spades                                      ; Jump to the spades printing section
	.ELSE                                             ; If suit is unrecognized
		jmp retout                                     ; Jump to retout to finish printing
	.ENDIF

heart:                                           ; Label for printing a Heart card
	call Gotoxy                                    ; Move cursor to the current card position
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline1                         ; Load the address of cardline1
	call WriteString                                ; Display the top line of the card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline2                         ; Load the address of cardline2
	call WriteString                                ; Display the second line of the card
	mov ax, (CARD PTR[esi]).Face                      ; Load the card's face into AX
	xchg al, ah                                     ; Exchange AL and AH for proper character display
	call WriteChar                                  ; Display the card's face character
	xchg al, ah                                     ; Exchange AL and AH back
	call WriteChar                                  ; Display the card's face character again
	mov edx, OFFSET cardline2a                        ; Load the address of cardline2a for Hearts
	call WriteString                                ; Display the additional heart-specific line
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline3a                        ; Load the address of cardline3a for Hearts
	call WriteString                                ; Display the third line of the Heart card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline4a                        ; Load the address of cardline4a for Hearts
	call WriteString                                ; Display the fourth line of the Heart card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline5a                        ; Load the address of cardline5a for Hearts
	call WriteString                                ; Display the fifth line of the Heart card
	xchg al, ah                                     ; Exchange AL and AH for proper character display
	call WriteChar                                  ; Display the card's face character
	xchg al, ah                                     ; Exchange AL and AH back
	call WriteChar                                  ; Display the card's face character again
	mov edx, OFFSET cardline6                         ; Load the address of cardline6
	call WriteString                                ; Display the sixth line of the card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline7                         ; Load the address of cardline7
	call WriteString                                ; Display the bottom line of the card
	pop edx                                        ; Restore EDX register from the stack
	add dl, 10                                     ; Move to the next card position horizontally
	add esi, TYPE CARD                              ; Move to the next card in the hand
	dec ecx                                         ; Decrement the loop counter
	jnz testcard                                    ; If not zero, continue printing cards
	jz  retout                                      ; If zero, finish printing

diamond:                                         ; Label for printing a Diamond card
	call Gotoxy                                    ; Move cursor to the current card position
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline1                         ; Load the address of cardline1
	call WriteString                                ; Display the top line of the card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline2                         ; Load the address of cardline2
	call WriteString                                ; Display the second line of the card
	mov ax, (CARD PTR[esi]).Face                      ; Load the card's face into AX
	xchg al, ah                                     ; Exchange AL and AH for proper character display
	call WriteChar                                  ; Display the card's face character
	xchg al, ah                                     ; Exchange AL and AH back
	call WriteChar                                  ; Display the card's face character again
	mov edx, OFFSET cardline2b                        ; Load the address of cardline2b for Diamonds
	call WriteString                                ; Display the additional diamond-specific line
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline3b                        ; Load the address of cardline3b for Diamonds
	call WriteString                                ; Display the third line of the Diamond card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline4b                        ; Load the address of cardline4b for Diamonds
	call WriteString                                ; Display the fourth line of the Diamond card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline5b                        ; Load the address of cardline5b for Diamonds
	call WriteString                                ; Display the fifth line of the Diamond card
	xchg al, ah                                     ; Exchange AL and AH for proper character display
	call WriteChar                                  ; Display the card's face character
	xchg al, ah                                     ; Exchange AL and AH back
	call WriteChar                                  ; Display the card's face character again
	mov edx, OFFSET cardline6                         ; Load the address of cardline6
	call WriteString                                ; Display the sixth line of the card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline7                         ; Load the address of cardline7
	call WriteString                                ; Display the bottom line of the card
	pop edx                                        ; Restore EDX register from the stack
	add dl, 10                                     ; Move to the next card position horizontally
	add esi, TYPE CARD                              ; Move to the next card in the hand
	dec ecx                                         ; Decrement the loop counter
	jnz testcard                                    ; If not zero, continue printing cards
	jz  retout                                      ; If zero, finish printing

clubs:                                           ; Label for printing a Clubs card
	call Gotoxy                                    ; Move cursor to the current card position
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline1                         ; Load the address of cardline1
	call WriteString                                ; Display the top line of the card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline2                         ; Load the address of cardline2
	call WriteString                                ; Display the second line of the card
	mov ax, (CARD PTR[esi]).Face                      ; Load the card's face into AX
	xchg al, ah                                     ; Exchange AL and AH for proper character display
	call WriteChar                                  ; Display the card's face character
	xchg al, ah                                     ; Exchange AL and AH back
	call WriteChar                                  ; Display the card's face character again
	mov edx, OFFSET cardline2c                        ; Load the address of cardline2c for Clubs
	call WriteString                                ; Display the additional club-specific line
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline3c                        ; Load the address of cardline3c for Clubs
	call WriteString                                ; Display the third line of the Clubs card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline4c                        ; Load the address of cardline4c for Clubs
	call WriteString                                ; Display the fourth line of the Clubs card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline5c                        ; Load the address of cardline5c for Clubs
	call WriteString                                ; Display the fifth line of the Clubs card
	xchg al, ah                                     ; Exchange AL and AH for proper character display
	call WriteChar                                  ; Display the card's face character
	xchg al, ah                                     ; Exchange AL and AH back
	call WriteChar                                  ; Display the card's face character again
	mov edx, OFFSET cardline6                         ; Load the address of cardline6
	call WriteString                                ; Display the sixth line of the card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline7                         ; Load the address of cardline7
	call WriteString                                ; Display the bottom line of the card
	pop edx                                        ; Restore EDX register from the stack
	add dl, 10                                     ; Move to the next card position horizontally
	add esi, TYPE CARD                              ; Move to the next card in the hand
	dec ecx                                         ; Decrement the loop counter
	jnz testcard                                    ; If not zero, continue printing cards
	jz  retout                                      ; If zero, finish printing

spades:                                          ; Label for printing a Spades card
	call Gotoxy                                    ; Move cursor to the current card position
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline1                         ; Load the address of cardline1
	call WriteString                                ; Display the top line of the card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline2                         ; Load the address of cardline2
	call WriteString                                ; Display the second line of the card
	mov ax, (CARD PTR[esi]).Face                      ; Load the card's face into AX
	xchg al, ah                                     ; Exchange AL and AH for proper character display
	call WriteChar                                  ; Display the card's face character
	xchg al, ah                                     ; Exchange AL and AH back
	call WriteChar                                  ; Display the card's face character again
	mov edx, OFFSET cardline2d                        ; Load the address of cardline2d for Spades
	call WriteString                                ; Display the additional spade-specific line
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline3d                        ; Load the address of cardline3d for Spades
	call WriteString                                ; Display the third line of the Spades card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline4d                        ; Load the address of cardline4d for Spades
	call WriteString                                ; Display the fourth line of the Spades card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline5d                        ; Load the address of cardline5d for Spades
	call WriteString                                ; Display the fifth line of the Spades card
	xchg al, ah                                     ; Exchange AL and AH for proper character display
	call WriteChar                                  ; Display the card's face character
	xchg al, ah                                     ; Exchange AL and AH back
	call WriteChar                                  ; Display the card's face character again
	mov edx, OFFSET cardline6                         ; Load the address of cardline6
	call WriteString                                ; Display the sixth line of the card
	pop edx                                        ; Restore EDX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline7                         ; Load the address of cardline7
	call WriteString                                ; Display the bottom line of the card
	pop edx                                        ; Restore EDX register from the stack
	add dl, 10                                     ; Move to the next card position horizontally
	add esi, TYPE CARD                              ; Move to the next card in the hand
	dec ecx                                         ; Decrement the loop counter
	jnz testcard                                    ; If not zero, continue printing cards
	jz  retout                                      ; If zero, finish printing

retout:                                          ; Label to finish printing hands
	call Crlf                                      ; Move the cursor to the next line
	pop esi                                        ; Restore ESI register from the stack
	pop edx                                        ; Restore EDX register from the stack
	pop ecx                                        ; Restore ECX register from the stack
	pop ebx                                        ; Restore EBX register from the stack
	pop eax                                        ; Restore EAX register from the stack
	ret                                            ; Return from PrintHand procedure

coverCard:                                        ; Procedure to cover the dealer's first card during player's turn
	mov dh, rowsToSkip                               ; Set vertical position to skip rows for covering card
	call Gotoxy                                    ; Move cursor to the specified position
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline1                         ; Load the address of cardline1
	call WriteString                                ; Display the top line of the blank card
	pop edx                                        ; Restore EDX register from the stack
	push ecx                                       ; Save ECX register on the stack
	mov ecx, 4                                     ; Set loop counter to 4 for the middle lines of the card

blankcardloop:                                    ; Loop label for drawing blank card
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET blankcard                         ; Load the address of blankcard
	call WriteString                                ; Display the blank card line
	pop edx                                        ; Restore EDX register from the stack
	LOOP blankcardloop                             ; Decrement ECX and loop if not zero

	pop ecx                                        ; Restore ECX register from the stack
	inc dh                                         ; Move to the next row
	call Gotoxy                                    ; Move cursor to the next row
	push edx                                       ; Save EDX register on the stack
	mov edx, OFFSET cardline7                         ; Load the address of cardline7
	call WriteString                                ; Display the bottom line of the blank card
	pop edx                                        ; Restore EDX register from the stack

	add dl, 10                                     ; Move to the next card position horizontally
	add esi, TYPE CARD                              ; Move to the next card in the hand
	dec ecx                                         ; Decrement the loop counter
	jnz testcard                                    ; If not zero, continue printing cards

PrintHand ENDP                                    ; End of PrintHand procedure

;---------------------------------------------------------------------------------------------------
; Procedure: AceCalculation
; Description:
;    Scans the specified hand for an Ace card when the hand's value exceeds 21.
;    If an Ace is found with a value of 11, it changes its value to 1 to prevent busting.
;
; Inputs:
;    turn:BYTE - Specifies which hand to check (1 for player, 0 for dealer)
;
; Outputs:
;    Modifies the value of an Ace from 11 to 1 if found
;    Updates playerValue or dealerValue accordingly
;
; Memory Usage:
;    Accesses playerHand or dealerHand to locate and modify Ace cards
;
; Registers Used:
;    EAX - Temporarily holds card values
;    ESI - Points to the hand being checked
;    ECX - Loop counter for iterating through cards
;
;---------------------------------------------------------------------------------------------------
AceCalculation PROC, turn:BYTE                     ; Begin AceCalculation procedure with turn parameter
	push eax                                       ; Save EAX register on the stack
	push esi                                       ; Save ESI register on the stack
	push ecx                                       ; Save ECX register on the stack

	mov ecx, 10                                     ; Set loop counter to 10 for each card in hand
	.IF (turn == 1)                                   ; If checking the player's hand
		mov esi, OFFSET playerHand                       ; Point ESI to playerHand
	.ELSE                                             ; If checking the dealer's hand
		mov esi, OFFSET dealerHand                       ; Point ESI to dealerHand
	.ENDIF

searchThrough:                                    ; Loop label for searching through the hand
	mov al, (CARD PTR[esi]).Value                       ; Load the value of the current card into AL
	.IF (al == 11)                                     ; If the card is an Ace valued at 11
		mov (CARD PTR[esi]).Value, 1                       ; Change the Ace's value to 1
		call addCards                                    ; Recalculate the hand's total value
		jmp donechecking                                ; Exit the loop after adjusting the Ace
	.ENDIF
	add esi, TYPE CARD                              ; Move to the next card in the hand
	LOOP searchThrough                             ; Decrement ECX and loop if not zero

donechecking:                                     ; Label marking the end of checking
	pop ecx                                        ; Restore ECX register from the stack
	pop esi                                        ; Restore ESI register from the stack
	pop eax                                        ; Restore EAX register from the stack
	ret                                            ; Return from AceCalculation procedure
AceCalculation ENDP                                    ; End of AceCalculation procedure

;---------------------------------------------------------------------------------------------------
; Procedure: addCards
; Description:
;    Recalculates the total values of both the player's and dealer's hands after an Ace's value
;    has been adjusted. Ensures that the hand values accurately reflect any changes made.
;
; Inputs:
;    None
;
; Outputs:
;    Updates playerValue and dealerValue by summing the values of their respective hands
;
; Memory Usage:
;    Accesses playerHand and dealerHand structures to sum card values
;
; Registers Used:
;    EAX - Accumulates player hand value
;    EBX - Accumulates dealer hand value
;    ESI - Points to playerHand for summing
;    EDI - Points to dealerHand for summing
;    ECX - Loop counter for iterating through cards
;
;---------------------------------------------------------------------------------------------------
addCards PROC                                      ; Begin addCards procedure
	push esi                                       ; Save ESI register on the stack
	push edi                                       ; Save EDI register on the stack
	push ecx                                       ; Save ECX register on the stack
	push eax                                       ; Save EAX register on the stack
	push ebx                                       ; Save EBX register on the stack

	mov playerValue, 0                              ; Reset playerValue to 0
	mov dealerValue, 0                              ; Reset dealerValue to 0
	mov eax, 0                                     ; Clear EAX register for summing
	mov ebx, 0                                     ; Clear EBX register for summing

	mov esi, OFFSET playerHand                       ; Point ESI to playerHand
	mov edi, OFFSET dealerHand                       ; Point EDI to dealerHand

	mov ecx, 10                                     ; Set loop counter to 10 for each card in hand

readd:                                            ; Loop label for summing card values
	add al, (CARD PTR[esi]).Value                       ; Add the player's card value to AL
	add bl, (CARD PTR[edi]).Value                       ; Add the dealer's card value to BL
	.IF (al == 0) && (bl == 0)                        ; If both card values are 0, no more cards to add
		jmp doneAdding                               ; Exit the loop
	.ENDIF
	add esi, TYPE CARD                              ; Move to the next player's card
	add edi, TYPE CARD                              ; Move to the next dealer's card
	LOOP readd                                     ; Decrement ECX and loop if not zero

doneAdding:                                       ; Label marking the end of adding cards
	mov playerValue, al                             ; Store the summed playerValue
	mov dealerValue, bl                             ; Store the summed dealerValue

	pop ebx                                        ; Restore EBX register from the stack
	pop eax                                        ; Restore EAX register from the stack
	pop ecx                                        ; Restore ECX register from the stack
	pop edi                                        ; Restore EDI register from the stack
	pop esi                                        ; Restore ESI register from the stack
	ret                                            ; Return from addCards procedure
addCards ENDP                                      ; End of addCards procedure

END main

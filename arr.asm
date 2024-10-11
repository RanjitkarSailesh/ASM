.386
.model flat, stdcall
.stack 4096
includelib C:\Irvine\Irvine32.lib
include C:\Irvine\Irvine32.inc

.data
    promptMsg   BYTE "Enter a non-negative integer: ", 0
    array       DWORD 25 DUP(0)        ; Array to store 25 integers
    space       BYTE " ", 0            ; Single space for formatting
    newline     BYTE 0Dh, 0Ah, 0       ; Newline for formatting
    filler      DWORD 1                ; Filler value initialized to 1
    maxValMsg   BYTE "The Maximum Array Value of the given Array is: ", 0
    minValMsg   BYTE "The Minimum Array Value of the given Array is: ", 0
    avgValMsg   BYTE "The Average Array Value of the given Array is: ", 0
    oddValMsg   BYTE "All the Odd Values in the given Array are: ", 0
    evenValMsg  BYTE "All the Even Values in the given Array are: ", 0
    repeatMsg   BYTE "Would you like to repeat the program? (Y/N): ", 0
    inputChar   BYTE ?
    
    ; Constant definitions to replace magic numbers
    arraySize   DWORD 25               ; Size of the array
    divisor     DWORD 25               ; Divisor for average calculation
    zero        DWORD 0                ; Constant 0 value for comparison

.code

main PROC
repeat_program:
    mov  filler, 1                     ; Reset autofill value to 1 at the start of the program

    mov  ecx, arraySize                ; Loop counter for arraySize numbers
    lea  edi, array                    ; Load address of the array into EDI
    mov  ebx, 0                        ; Count the number of user inputs

input_loop:
    ; Prompt the user to enter a number
    mov  edx, OFFSET promptMsg
    call WriteString
    
    ; Read the number from user
    call ReadInt
    
    ; Check if the user pressed Enter without entering a number
    cmp  eax, zero                     ; Compare input to zero
    je   fill_array                    ; If 0 is entered, fill the remaining array

    ; Store the number in the array
    mov  [edi], eax
    
    ; Move to the next element in the array
    add  edi, 4

    ; Increment the user input counter
    inc  ebx
    
    ; Decrement the loop counter and check if we got arraySize numbers
    loop input_loop

fill_array:
    ; If user entered less than arraySize numbers, fill the remaining with sequential numbers
    cmp  ebx, arraySize                ; Check if less than arraySize numbers were entered
    jge  next_step                     ; If arraySize numbers were entered, skip filling

fill_loop:
    mov  eax, filler                   ; Load the filler value
    mov  [edi], eax                    ; Store the filler value in the array
    add  edi, 4                        ; Move to the next element in the array
    inc  filler                        ; Increment the filler value

    ; Increment the user input count and check if the array is full
    inc  ebx
    cmp  ebx, arraySize
    jl   fill_loop                     ; Continue filling until array has arraySize numbers

next_step:
    ; Call procedures to find maximum, minimum, average, odd, and even values
    call FindMaxMin
    call FindAverage
    call FindOddValues
    call FindEvenValues

    ; Ask the user if they want to repeat the program
    call RepeatPrompt

    ; Exit the program if user chooses not to repeat
    cmp  inputChar, 'Y'
    je   repeat_program                ; If 'Y', repeat the program
    cmp  inputChar, 'y'
    je   repeat_program                ; If 'y', repeat the program

    ; Exit the program
    call WaitMsg
    exit
main ENDP

;-----------------------------------------------------
; Procedure: FindMaxMin
; Purpose: Finds the maximum and minimum values in the array
;-----------------------------------------------------
FindMaxMin PROC
    ; Initialize EAX and EBX
    lea  edi, array                    ; Load array start address
    mov  ecx, arraySize                ; Array size

    ; Initialize max and min to the first element
    mov  eax, [edi]                    ; EAX holds max value
    mov  ebx, [edi]                    ; EBX holds min value

    add  edi, 4                        ; Move to the next element
    dec  ecx                           ; We already compared the first element

find_loop:
    mov  edx, [edi]                    ; Load current element in EDX
    
    ; Compare with max value in EAX
    cmp  edx, eax
    jle  check_min
    mov  eax, edx                      ; Update max if EDX is greater

check_min:
    ; Compare with min value in EBX
    cmp  edx, ebx
    jge  next_element
    mov  ebx, edx                      ; Update min if EDX is smaller

next_element:
    add  edi, 4                        ; Move to next element in the array
    loop find_loop                     ; Repeat for all elements

    ; Print the maximum value
    mov  edx, OFFSET newline
    call WriteString
    mov  edx, OFFSET maxValMsg
    call WriteString
    mov  eax, eax                      ; EAX holds the max value
    call WriteDec
    
    ; Print the minimum value
    mov  edx, OFFSET newline
    call WriteString
    mov  edx, OFFSET minValMsg
    call WriteString
    mov  eax, ebx                      ; EBX holds the min value
    call WriteDec
    mov  edx, OFFSET newline
    call WriteString

    ret
FindMaxMin ENDP

;-----------------------------------------------------
; Procedure: FindAverage
; Purpose: Calculates and prints the average value of the array
;-----------------------------------------------------
FindAverage PROC
    ; Initialize variables
    lea  edi, array                    ; Load array start address
    mov  ecx, arraySize                ; Array size
    xor  eax, eax                      ; Clear EAX (will hold sum)

sum_loop:
    add  eax, [edi]                    ; Add current element to EAX
    add  edi, 4                        ; Move to next element
    loop sum_loop                      ; Repeat for all elements

    ; Calculate the average by dividing the sum by arraySize
    mov  edx, zero                     ; Clear EDX before division
    mov  ecx, divisor                  ; Divisor for average calculation
    div  ecx                           ; EAX = sum / divisor (average)

    ; Print the average value
    mov  edx, OFFSET avgValMsg
    call WriteString
    call WriteDec
    mov  edx, OFFSET newline
    call WriteString

    ret
FindAverage ENDP

;-----------------------------------------------------
; Procedure: FindOddValues
; Purpose: Finds and prints all the odd values in the array
;-----------------------------------------------------
FindOddValues PROC
    mov  edx, OFFSET newline
    call WriteString
    mov  edx, OFFSET oddValMsg
    call WriteString

    lea  edi, array                    ; Load array start address
    mov  ecx, arraySize                ; Array size

find_odd_loop:
    mov  eax, [edi]                    ; Load current element in EAX
    test eax, 1                        ; Test the least significant bit (odd if set)
    jz   skip_odd                      ; If zero, the number is even, skip

    ; Print the odd number
    call WriteDec
    mov  edx, OFFSET space
    call WriteString

skip_odd:
    add  edi, 4                        ; Move to the next element in the array
    loop find_odd_loop

    ret
FindOddValues ENDP

;-----------------------------------------------------
; Procedure: FindEvenValues
; Purpose: Finds and prints all the even values in the array
;-----------------------------------------------------
FindEvenValues PROC
    mov  edx, OFFSET newline
    call WriteString
    mov  edx, OFFSET evenValMsg
    call WriteString

    lea  edi, array                    ; Load array start address
    mov  ecx, arraySize                ; Array size

find_even_loop:
    mov  eax, [edi]                    ; Load current element in EAX
    test eax, 1                        ; Test the least significant bit (even if zero)
    jnz  skip_even                     ; If non-zero, the number is odd, skip

    ; Print the even number
    call WriteDec
    mov  edx, OFFSET space
    call WriteString

skip_even:
    add  edi, 4                        ; Move to the next element in the array
    loop find_even_loop

    ; Print a newline after all even values
    mov  edx, OFFSET newline
    call WriteString

    ret
FindEvenValues ENDP

;-----------------------------------------------------
; Procedure: RepeatPrompt
; Purpose: Asks the user if they want to repeat the program
;-----------------------------------------------------
RepeatPrompt PROC
    ; Prompt the user for input (Y/N)
    mov  edx, OFFSET newline
    call WriteString
    mov  edx, OFFSET repeatMsg
    call WriteString
    call ReadChar                     ; Read a character from the user
    mov  inputChar, al                ; Store the user input
    mov  edx, OFFSET newline
    call WriteString

    ret
RepeatPrompt ENDP

END main

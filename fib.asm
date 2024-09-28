;-------------------------------------------------------------------------------
; Description:
; This program generates and saves first 26 Fibonacci’s number in the memory.
; The Fibonacci numbers are to be stored in the ‘FibNumbers’ array and this program employs a loop to get the next Fibonacci number using the sum of the two previous numbers
;-------------------------------------------------------------------------------
.386
.model flat, stdcall
.stack 4096                  ; Allocate 4KB for the stack
ExitProcess proto,dwExitCode:dword

.data                        ; Data section for storing Fibonacci numbers   

; Define space to store the first 26 Fibonacci numbers
FibNumbers DWORD 26 dup(?)

.code                       ; Code section for program logic
;-------------------------------------------------------------------------------
; Procedure:   main
; Inputs:      None
; Outputs:     None (Fibonacci numbers are stored in memory)
; Registers:   EAX, EBX, ECX, EDI
; Description:
; This procedure starts with the first two Fibonacci numbers being 0 and 1 and utilizes a loop to evaluate and save the successive 24 Fibonacci numbers in the FibNumbers
; It continues to loop until all 26 numbers are called and then the program ends.
;-------------------------------------------------------------------------------

main proc
    ; Initialize registers
    mov eax, 0                  ; Fib(0) = 0
    mov [FibNumbers], eax ; Store Fib(0) in memory
    mov ebx, 1                  ; Fib(1) = 1
    mov [FibNumbers + 4], ebx ; Store Fib(1) in memory
    
    ; Set up loop variables
    mov ecx, 2                  ; Start from the 3rd Fib number (index 2)
    mov edi, offset FibNumbers

generate_fib:
    ; Calculate Fib(n) = Fib(n-1) + Fib(n-2)
    mov eax, [edi + ecx*4 - 4]  ; Load Fib(n-1)
    add eax, [edi + ecx*4 - 8]  ; Add Fib(n-2)
    
    ; Store the result in memory
    mov [edi + ecx*4], eax
    
    ; Increment index and check if we have processed 26 numbers
    inc ecx
    cmp ecx, 26
    jl generate_fib       ; Loop if ecx < 26

    ; Exit the program 
    invoke ExitProcess, 0

main ENDP
end main

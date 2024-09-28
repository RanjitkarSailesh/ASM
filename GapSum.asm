;-------------------------------------------------------------------------------
; Name:        [Sailesh Ranjitkar]
; Course:      [CSC2025, X00], [Computer Arch/Assembly]
; Program:     Calculate Gaps In Array
; Date:        [9/20/2024]
;
; Description:
; Calculates the sum of the gaps between each element in the array
;-------------------------------------------------------------------------------

.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
dwarray dword  0, 2, 5, 9, 10, 15, 17, 23, 25, 25  ; Array of integers
count EQU (LENGTHOF dwarray)    ; Number of elements in the array
total dword 0                   ; Variable to store the sum of gaps
;------------------------------------------------------------
; main procedure
; Inputs: None 
; Outputs: Total sum of gaps stored in 'total'
; Memory Usage: dwarray (input), total (output)
; Register Usage: 
;   - ESI: Points to current element in the array
;   - ECX: Counter for the number of gaps
;   - EAX: Holds current array element
;   - EBX: Holds next array element
; Functional Description: Calculates the sum of gaps between consecutive elements in dwarray.
;------------------------------------------------------------
.code
main proc
    mov esi, OFFSET dwarray     ; Set the offset for proper incrementation
    mov ecx, count - 1          ; Set ecx to count - 1 (since there are count - 1 gaps)

L1:
    mov eax, [esi]              ; Move the current array element into eax
    add esi, 4                  ; Increment esi to point to the next element
    mov ebx, [esi]              ; Move the next array element into ebx
    
    sub ebx, eax                ; Calculate the gap (next - current)
    add [total], ebx            ; Add the gap to the running total

    loop L1                     ; Repeat the loop until ecx reaches 0

    ; Exit the program
    invoke ExitProcess, 0
main endp
end main

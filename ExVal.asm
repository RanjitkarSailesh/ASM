;-------------------------------------------------------------------------------
; Name:        [Sailesh Ranjitkar]
; Course:      [CSC2025, X00], [Computer Arch/Assembly]
; Program:     Swap Each Pair of an Array
; Date:        [9/20/2024]
;
; Description:
; Swap Adjacent Elements of Array in pairs of two
;-------------------------------------------------------------------------------

.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
array DWORD 1, 2, 3, 4, 5, 6, 7, 8    ; Array with 8 elements
;------------------------------------------------------------
; main procedure
; Inputs: None 
; Outputs: The elements of array are swapped in pairs
; Memory Usage: array as both input and output
; Register Usage: 
;   - ESI: Points to the current pair in the array
;   - ECX: Counter for the number of pairs (4 pairs for 8 elements)
;   - EAX: Temporarily holds the value of the first element in the pair
;   - EBX: Temporarily holds the value of the second element in the pair
; Functional Description: Swaps adjacent elements in the array in pairs.
;------------------------------------------------------------
.code
main PROC
    ; ESI points to the start of the array
    mov esi, OFFSET array              ; ESI points to the start of array
    
    ; ECX holds the number of pairs (4 pairs for 8 elements)
    mov ecx, LENGTHOF array / 2        ; ECX = 4

TheLoop: ; Loop 4 times
    ; Swap the first pair (i and i + 1)
    mov eax, [esi]                     ; EAX = array[i]
    mov ebx, [esi + 4]                 ; EBX = array[i + 1]
    mov [esi], ebx                     ; array[i] = array[i + 1]
    mov [esi + 4], eax                 ; array[i + 1] = array[i]
    
    ; Move to the next pair
    add esi, 8                          ; Move to the next pair (2 DWORDs = 8 bytes)
    
    ; Swap the second pair (i + 2 and i + 3)
    mov eax, [esi]                     ; EAX = array[i + 2]
    mov ebx, [esi + 4]                 ; EBX = array[i + 3]
    mov [esi], ebx                     ; array[i + 2] = array[i + 3]
    mov [esi + 4], eax                 ; array[i + 3] = array[i + 2]
    
    ; Move to the next pair (to prepare for the next iteration)
    add esi, 8                          ; Move to the next pair (2 DWORDs = 8 bytes)
    
    ; Decrement ECX and continue if ECX is non-zero
    loop TheLoop

    ; Exit the program
    invoke ExitProcess, 0
main ENDP
END main

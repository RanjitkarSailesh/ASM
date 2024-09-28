;-------------------------------------------------------------------------------
; Description:
; Reverses the element of an array
;-------------------------------------------------------------------------------

.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
dwarray dword  6,7,5,3,9,1,4,8,2,0  ; Array of integers
count   EQU (LENGTHOF dwarray)                ; Number of elements in the array
;------------------------------------------------------------
; main procedure
; Inputs: None 
; Outputs: Elements of dwarray are reversed in place
; Memory Usage: dwarray (input/output)
; Register Usage: 
;   - ESI: Points to the current element from the start
;   - EDI: Points to the current element from the end
;   - ECX: Counter for the number of swaps
;   - EAX: Temporarily holds the value of the current element at ESI
;   - EBX: Temporarily holds the value of the current element at EDI
; Functional Description: Reverses the elements of dwarray in place.
;------------------------------------------------------------
.code
main proc
    mov esi, OFFSET dwarray         ; ESI points to the start of the array
    mov edi, OFFSET dwarray         ; EDI points to the start of the array
    add edi, SIZEOF dwarray         ; EDI points to byte after the end of the array
    sub edi, TYPE dwarray           ; Adjust EDI to point to the last element

    mov ecx, count                  ; ECX holds the total number of elements
    shr ecx, 1                      ; Divide ECX by 2 (since we'll swap half the array)

reverse_loop:
    cmp esi, edi                    ; Check if the pointers have crossed
    jge done                        ; Exit if the pointers have crossed

    ; Swap elements at ESI and EDI
    mov eax, [esi]                  ; Load element at ESI into EAX
    mov ebx, [edi]                  ; Load element at EDI into EBX
    mov [esi], ebx                  ; Store EBX at ESI
    mov [edi], eax                  ; Store EAX at EDI

    ; Move ESI forward, EDI backward
    add esi, TYPE dwarray           ; Move ESI to the next element (forward)
    sub edi, TYPE dwarray           ; Move EDI to the previous element (backward)

    loop reverse_loop               ; Repeat the loop

done:
    ; Exit the program
    invoke ExitProcess, 0
main endp
end main

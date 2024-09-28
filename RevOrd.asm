;-------------------------------------------------------------------------------
; Description:
; Reverses the element of an array
;-------------------------------------------------------------------------------

.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:DWORD

.data
    source BYTE "This is the source string", 0  ; Source string (null-terminated)
    target BYTE SIZEOF source DUP('#')         ; Target buffer, initialized with '#'
;------------------------------------------------------------
; main procedure
; Inputs: None 
; Outputs: target contains the reversed string
; Memory Usage: source as input and target as output
; Register Usage: 
;   - ESI: Points to the current character in the source string
;   - EDI: Points to the current position in the target buffer
;   - ECX: Counter for the length of the source string
;   - AL: Temporarily holds the value of the current character
; Functional Description: Copies the source string to the target buffer in reverse order.
;------------------------------------------------------------
.code
main PROC
    mov esi, OFFSET source    ; ESI points to the start of the source string
    mov edi, OFFSET target    ; EDI points to the start of the target buffer

    ; Find the length of the string (excluding null terminator)
    mov ecx, SIZEOF source    ; ECX = size of source
    dec ecx                   ; Adjust for null terminator, ECX = length of the string

    ; Set ESI to point to the last character of the source (before null terminator)
    add esi, ecx              ; ESI = address of the last character in source

    ; Copy and reverse the string
    rloop:
        mov al, [esi]          ; Load byte from source (ESI) into AL
        mov [edi], al          ; Store byte from AL into target (EDI)
        dec esi                ; Move ESI to previous character in source
        inc edi                ; Move EDI to the next position in target
        loop rloop      ; Repeat until ECX = 0

    ; Null-terminate the target string
    mov byte ptr [edi], 0

    ; Exit the program
    invoke ExitProcess, 0
main ENDP
END main

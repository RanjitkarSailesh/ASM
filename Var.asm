;-------------------------------------------------------------------------------
; Description:
; This program show simple arithmetic operations in assembly
; The result of (varA + varB) - (varC + varD) is stored in the 'Result' variable and the program exits with this result as the exit code.
;-------------------------------------------------------------------------------

    .386            ; Use 32-bit instructions
    .model flat, stdcall
    .stack 4096     ; Define the stack size
    ExitProcess proto,dwExitCode:dword
    .data           ; Data section for initializing variables
        varA    DWORD   18          ; Value for varA
        varB    DWORD   27          ; Value for varB
        varC    DWORD   32           ; Value for varC
        varD    DWORD   11          ; Value for varD
        Result  DWORD   ?           ; Variable to store the result
;-------------------------------------------------------------------------------
; Procedure:   main
; Inputs:      None
; Outputs:     Exit code (Result)
; Registers:   EAX, EBX
; Description:
; The following procedure takes in varA and varB, then adds the two and stores the result in EAX,  
; then it takes in varC and varD and adds the two. keeping that result in EBX
; Then it subtract the result from (varC + varD) from (varA + varB) then saves the result in ‘Result’ variable before the program ends.
;-------------------------------------------------------------------------------
    .code           ; Code section for the program logic
    main proc
        ; Load varA into EAX
        mov eax, varA                ; EAX = varA
        add eax, varB                ; EAX = varA + varB

        ; Load varC into EBX
        mov ebx, varC                ; EBX = varC
        add ebx, varD                ; EBX = varC + varD

        ; Subtract (varC + varD) from (varA + varB)
        sub eax, ebx                 ; EAX = (varA + varB) - (varC + varD)

        ; Store the result in the Result variable
        mov Result, eax              ; Result = EAX

        ; Exit program
        invoke ExitProcess, Result
    main ENDP
    END main

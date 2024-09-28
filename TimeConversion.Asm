.386
.model flat, stdcall
.stack 4096
includelib C:\Irvine\Irvine32.lib  ; Include the Irvine32 library
include C:\Irvine\Irvine32.inc     ; Include the Irvine32 macros

ExitProcess PROTO, dwExitCode:DWORD

.data
    promptHours    BYTE "Enter the number of hours: ", 0
    promptMinutes  BYTE "Enter the number of minutes: ", 0
    promptSeconds  BYTE "Enter the number of seconds: ", 0
    errorMessage   BYTE "Invalid input. Please enter a numeric value.", 0
    promptRepeat   BYTE "Try again (y/n)? ", 0
    hoursLabel     BYTE "The number of hours entered was: ", 0
    minutesLabel   BYTE "The number of minutes entered was: ", 0
    secondsLabel   BYTE "The number of seconds entered was: ", 0
    totalMinutesLabel BYTE "The total number of minutes is: ", 0
    totalSecondsLabel BYTE "The total number of seconds is: ", 0
    repeatAnswer   BYTE 2 DUP(?)
    
    hours          DWORD ?
    minutes        DWORD ?
    seconds        DWORD ?
    totalSeconds   DWORD ?
    totalMinutes   DWORD ?

.code
main PROC
repeatProgram:
    ; Clear previous values
    mov hours, 0
    mov minutes, 0
    mov seconds, 0
    mov totalSeconds, 0
    mov totalMinutes, 0

    ; Input hours
    mov edx, OFFSET promptHours
    call WriteString
    call GetValidInput
    mov hours, eax
    
    ; Input minutes
    mov edx, OFFSET promptMinutes
    call WriteString
    call GetValidInput
    mov minutes, eax
    
    ; Input seconds
    mov edx, OFFSET promptSeconds
    call WriteString
    call GetValidInput
    mov seconds, eax

    ; Output the original inputs
    mov edx, OFFSET hoursLabel
    call WriteString
    mov eax, hours
    call WriteDec
    call Crlf
    
    mov edx, OFFSET minutesLabel
    call WriteString
    mov eax, minutes
    call WriteDec
    call Crlf
    
    mov edx, OFFSET secondsLabel
    call WriteString
    mov eax, seconds
    call WriteDec
    call Crlf

    ; Calculate total minutes
    mov eax, hours            ; Load hours into eax
    imul eax, 60              ; Convert hours to minutes
    mov totalMinutes, eax      ; Store hours in totalMinutes

    mov eax, minutes          ; Load minutes into eax
    add totalMinutes, eax      ; Add minutes to totalMinutes

    ; Convert total minutes to seconds
    mov eax, totalMinutes      ; Load totalMinutes into eax
    imul eax, 60               ; Convert total minutes to seconds
    add totalSeconds, eax      ; Add converted minutes to totalSeconds
    mov eax, seconds         ; Load seconds into eax
    add totalSeconds, eax    ; Add remaining seconds to totalSeconds
    
    ; Output total time
    mov edx, OFFSET totalMinutesLabel
    call WriteString
    mov eax, totalMinutes
    call WriteDec
    call Crlf

    mov eax, OFFSET totalSecondsLabel
    call WriteString
    mov eax, totalSeconds
    call WriteDec
    call Crlf

    ; Ask user to repeat
    mov edx, OFFSET promptRepeat
    call WriteString
    call ReadString
    movzx eax, repeatAnswer[0]   ; Read the first character of the response
    or al, 20                     ; Convert to lowercase
    cmp al, 'y'
    je repeatProgram              ; If user presses 'y', repeat the program
    
    ; Exit program
    call Crlf
    call WaitMsg
    invoke ExitProcess, 0

main ENDP

GetValidInput PROC
    ; Loop to get valid input
    REPEAT_INPUT:
        call ReadInt             ; Read input from user
        .IF eax == -1
            mov edx, OFFSET errorMessage
            call WriteString
            call Crlf
            jmp REPEAT_INPUT      ; Re-prompt input if invalid
        .ENDIF
    ret
GetValidInput ENDP

END main

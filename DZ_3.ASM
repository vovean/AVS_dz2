;??????? 5
;????????? ?????? B ?? ????????? A, ???????? ??????? ?? ????????? ? ????????? ?????? x

format PE console
 
include 'win32a.inc'
 
entry start
 
section '.data' data readable writable
 
        ;strings to be printed later
        arrSizePrompt               db 'Input the size of the array (0 to 100 inclusive)', 10, 0
        strInvalidArrSize           db 'Invalid size of array: %d (press any key to exit)', 10, 0
        strReadArrEl                db 'Input element index [%d]: ', 0
        strInputX                   db 'Input x: ', 0
        strReadInt                  db '%d', 0
        strLeftArrBracket           db '[', 0
        strRightArrBracket          db ']', 10, 0
        strOneInt                   db '%d ', 0
        strArrA                     db 'Array A: ', 0
        strArrB                     db 'Array B: ', 0

        ;variables for future use
        arrA                        rd 100
        arrB                        rd 100
        arrA_size                   dd 0
        arrB_size                   dd 0
        x                           dd ?
        tmp                         dd ?
        tmpB                        dd ?
        registriesInStackPtr        dd ?
        i                           dd ?
 
 
section '.code' code readable executable
 
;========================= BEGIN input array from user BEGIN =========================
        readArr:
                ;preserve registries
                push eax
                mov  eax, esp
                push ecx
                push edx
 
                xor  ecx, ecx ;ecx = 0
                mov  edx, [ss:eax+8+0]
 
        inputArrLoop:
                ;preserve registries
                mov  [registriesInStackPtr], eax
                mov  [tmp], edx
                mov  [i], ecx
 
                cmp  ecx, [ss:eax+8+4] ; array size
                jge  endInputArrLoop ; if >= than we are out of the array

                push ecx ;current index
                push strReadArrEl ; Input element index [%d]: 
                call [printf] 

                ;read new element into tmp
                push [tmp]
                push strReadInt
                call [scanf]

                ; move counter
                mov  ecx, [i]
                inc  ecx
                ;restore registries
                mov  edx, [tmp]
                ;move array element pointer
                add  edx, 4
                mov  eax, [registriesInStackPtr]
                ;recursion
                jmp  inputArrLoop
 
        endInputArrLoop:
                sub  eax, 8
                mov  esp, eax
                ;restore registries
                pop  edx
                pop  ecx
                pop  eax
 
        ret
;========================= END input array from user END =========================
 
 
;========================= BEGIN remove elements of array whuch mach with user number BEGIN =========================
 
        createArrWithoutX:
                ;preserve
                                ;print array A prompt registries
                push eax
                mov  eax, esp
                push ecx
                                ;print array A elements
                push edx
                push ebx
 
                mov  edx, [ss:eax+8+4] ;1st array pointer
                mov  ebx, [ss:eax+8+0] ;2nd array pointer
 
                xor  ecx, ecx ;set ecx to 0
 
        arrWithoutXLoop:
                ;preserve registries
                mov  [tmp], edx
                mov  [tmpB], ebx
                mov  [i], ecx
 

                cmp  ecx, [ss:eax+8+8] ;1st array size
                jge  endArrWithoutXLoop ; if array ends
 
                ;check if need to delete
                mov  ecx, [x]
                cmp  [edx], ecx
                je   equalWithX
 
                ;add element to new array and inc another element counter
                mov  ecx, [edx]
                mov  [ebx], ecx
                mov  ebx, [tmpB]
                add  ebx, 4
                inc  [arrB_size]
 
        equalWithX:
                ;get next array element
                mov  ecx, [i]
                inc  ecx
                mov  edx, [tmp]
                add  edx, 4
                jmp  arrWithoutXLoop
 
 
        endArrWithoutXLoop:
                ;restore registries
                sub  eax, 12
                mov  esp, eax
                pop  ebx
                pop  edx
                pop  ecx
                pop  eax
 
        ret
 
;========================= END remove elements of array whuch mach with user number END =========================
 
 
;========================= BEGIN print array to screen iteratively BEGIN =========================
 
        printArr:
                ;preserve registries
                push eax
                mov  eax, esp
                push ecx
                push edx

                mov  [registriesInStackPtr], eax
 
                push strLeftArrBracket ;[
                call [printf]
 
                ;restore eax
                mov  eax, [registriesInStackPtr]
 
                xor  ecx, ecx ;ecx = 0
                mov  edx, [ss:eax+8+0] ;set edx to point to 1st array element
 
        printArrInLoop:
                ;preserve registries
                mov  [tmp], edx
                mov  [i], ecx
 
                cmp  ecx, [ss:eax+8+4] ;check if we are still in array
                jge  endPrintArrInLoop
 
                mov  ecx, [edx]
                push ecx          ;get array element
                push strOneInt       ; %d,
                call [printf]
 
                ;move to next element
                ;restore registries
                mov  edx, [tmp]
                add  edx, 4
                mov  ecx, [i]
                inc  ecx
                mov  eax, [registriesInStackPtr]
                jmp  printArrInLoop  ; recursion
 
        endPrintArrInLoop:
                push strRightArrBracket ;]
                call [printf]
 
                ;restore registries
                mov  eax, [registriesInStackPtr]

                sub  eax, 8
                mov  esp, eax
                pop  edx
                pop  ecx
                pop  eax
 
        ret
 
;========================= END print array to screen iteratively END =========================
 
;========================= BEGIN main part BEGIN =========================
        start:
                ;ask to input array size
                push arrSizePrompt
                call [printf]
                
                ;read array size
                push arrA_size
                push strReadInt
                call [scanf]
 
                ;input array size
                mov  eax, [arrA_size]
                cmp  eax, 0
                jle  invalidArrSize

                ;check size less 100
                mov  eax, [arrA_size]
                cmp  eax, 100
                jg  invalidArrSize
 
                ;read whole array recursively
                push [arrA_size]
                push arrA
                call readArr

                ;prompt for number to be excluded from array
                push strInputX
                call [printf]

                ;input num to remove array
                push x
                push strReadInt
                call [scanf]

                ;delete input number from array
                push [arrA_size]
                push arrA
                push arrB
                call createArrWithoutX

                ;print array A prompt
                push strArrA
                call [printf]
 
                ;print array A elements
                push [arrA_size]
                push arrA
                call printArr
 
                ;print array B prompt
                push strArrB
                call [printf]
 
                ;print array B
                push [arrB_size]
                push arrB
                call printArr

                jmp endProgram

        invalidArrSize:
                ;Invalid array size
                push [arrA_size]
                push strInvalidArrSize
                call [printf]

 
        endProgram:
                ;wait for user to press something before close console windows
                call [getch] 
                push 0
                call ExitProcess
;========================= END main part END =========================
 
section '.idata' data readable import
 
        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'
 
        import kernel,\
               ExitProcess, 'ExitProcess'
 
        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'
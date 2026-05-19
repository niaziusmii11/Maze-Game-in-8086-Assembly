; ============================================================
;   MAZE GAME - 8086 Assembly | CEN323 | emu8086
;   Arrow Keys = Move    ESC = Quit
; ============================================================
.model small
.stack 200h

.data

ROWS EQU 11
COLS EQU 15


maze DB '###############'
     DB '#S  #   #     #'
     DB '### # # ### # #'
     DB '#     #   #   #'
     DB '# ####### # ###'
     DB '# #     #   # #'
     DB '# # ### ### # #'
     DB '#   #     #   #'
     DB '### # ### ### #'
     DB '#     #      E#'
     DB '###############'

player_row DB 1
player_col DB 1
moves      DW 0

crlf    DB 13,10,'$'
hdr1    DB '===== MAZE GAME - CEN323 8086 =====',13,10,'$'
hdr2    DB 'Arrow Keys=Move   ESC=Quit',13,10,'$'
hdr3    DB '===================================',13,10,'$'
smoves  DB 13,10,'Moves: $'
swin    DB 13,10,'*** YOU WIN! Congratulations! ***',13,10,'$'
sany    DB 'Press ESC to exit...$'

.code

main PROC
    mov ax, @data
    mov ds, ax

    mov ax, 0003h
    int 10h

    call redraw

game_loop:
    mov ah, 00h
    int 16h

    cmp al, 1Bh
    je  bye

    cmp al, 00h
    jne game_loop

    cmp ah, 48h
    je  do_up
    cmp ah, 50h
    je  do_dn
    cmp ah, 4Bh
    je  do_lt
    cmp ah, 4Dh
    je  do_rt
    jmp game_loop

do_up:
    call try_up
    jmp game_loop
do_dn:
    call try_dn
    jmp game_loop
do_lt:
    call try_lt
    jmp game_loop
do_rt:
    call try_rt
    jmp game_loop

bye:
    mov ax, 4C00h
    int 21h
main ENDP



try_up PROC
    push ax
    push bx
    push cx
    push dx
    push si

    
    mov al, player_row
    cmp al, 0
    je  tu_done        
    dec al
    mov cl, al         
    mov ch, player_col  

    call check_and_move

tu_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
try_up ENDP

try_dn PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov al, player_row
    inc al
    cmp al, ROWS
    jge td_done
    mov cl, al
    mov ch, player_col

    call check_and_move

td_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
try_dn ENDP

try_lt PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov al, player_col
    cmp al, 0
    je  tl_done
    dec al
    mov ch, al
    mov cl, player_row

    call check_and_move

tl_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
try_lt ENDP

try_rt PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov al, player_col
    inc al
    cmp al, COLS
    jge tr_done
    mov ch, al
    mov cl, player_row

    call check_and_move

tr_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
try_rt ENDP


check_and_move PROC
    push ax
    push bx
    push dx
    push si

  
    xor ax, ax
    mov al, cl          
    mov bl, COLS
    mul bl              
    xor bx, bx
    mov bl, ch         
    add ax, bx
    mov si, ax

    mov al, maze[si]   

    cmp al, '#'
    je  cam_done       

   
    mov player_row, cl
    mov player_col, ch
    inc moves

    cmp al, 'E'
    je  cam_win

    call redraw
    jmp cam_done

cam_win:
    call redraw
    mov ah, 09h
    mov dx, OFFSET swin
    int 21h
    mov dx, OFFSET sany
    int 21h
    ; wait for ESC
wkey:
    mov ah, 00h
    int 16h
    cmp al, 1Bh
    jne wkey
    mov ax, 4C00h
    int 21h

cam_done:
    pop si
    pop dx
    pop bx
    pop ax
    ret
check_and_move ENDP


redraw PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov ax, 0003h
    int 10h

    mov ah, 09h
    mov dx, OFFSET hdr1
    int 21h
    mov dx, OFFSET hdr2
    int 21h
    mov dx, OFFSET hdr3
    int 21h

    xor cx, cx

rd_row:
    cmp cl, ROWS
    jge rd_done

    xor bx, bx

rd_col:
    cmp bl, COLS
    jge rd_eol

   
    mov al, cl
    cmp al, player_row
    jne rd_maze
    mov al, bl
    cmp al, player_col
    jne rd_maze

    
    mov ah, 02h
    mov dl, '@'
    int 21h
    jmp rd_nc

rd_maze:
   
    push cx
    push bx
    xor ax, ax
    mov al, cl
    mov dl, COLS
    mul dl
    xor bh, bh
    add al, bl
    adc ah, 0
    mov si, ax
    mov dl, maze[si]
    pop bx
    pop cx
    mov ah, 02h
    int 21h

rd_nc:
    inc bl
    jmp rd_col

rd_eol:
    mov ah, 09h
    mov dx, OFFSET crlf
    int 21h
    inc cl
    jmp rd_row

rd_done:
    mov ah, 09h
    mov dx, OFFSET smoves
    int 21h

    
    mov ax, moves
    mov bx, 10
    mov cx, 0
pn_push:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne pn_push
pn_pop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop pn_pop

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
redraw ENDP

END main

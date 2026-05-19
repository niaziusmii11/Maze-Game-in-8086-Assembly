; ============================================================
;   MAZE GAME - 8086 Assembly Language
;   CEN323 Semester Project - Phase 2
;   Bahria University
;   Group Members:
;     Muhammad Usman Khan  - 01-135232-072
;     Muhammad Talha       - 01-135232-069
;
;   Controls: Arrow Keys = Move   ESC = Quit
;
;   Assembly Concepts Used:
;   1. Registers (AX,BX,CX,DX,SI)
;   2. Procedures (PROC/ENDP)
;   3. Conditional Jumps (JE,JNE,JGE,JA)
;   4. Loops (LOOP instruction + manual loops)
;   5. Arrays/Memory (maze byte array, indexed access)
;   6. Stack (PUSH/POP in every procedure)
;   7. Arithmetic (MUL for 2D indexing, INC, DEC)
;   8. Interrupts (INT 10h, INT 16h, INT 21h)
;   9. String Operations ($ terminated strings)
;  10. Comparison (CMP instruction throughout)
;  11. Data Segment variables
;  12. Modular Design (separate proc per function)
; ============================================================

.model small
.stack 200h

.data

; ---- Maze Dimensions ----
ROWS EQU 11
COLS EQU 15

; ---- Maze Map (stored as flat byte array in Data Segment) ----
; '#' = wall   ' ' = open path   'S' = start   'E' = exit
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

; ---- Player State (stored in Data Segment) ----
player_row  DB 1        ; current row of player
player_col  DB 1        ; current col of player
new_row     DB 0        ; candidate new row (after key press)
new_col     DB 0        ; candidate new col (after key press)
moves       DW 0        ; move counter (16-bit word)
score       DW 500      ; score (starts 500, -1 per move)

; ---- DOS Strings ($ terminated for INT 21h AH=09h) ----
crlf    DB 13,10,'$'
hdr1    DB '================================================',13,10,'$'
hdr2    DB '        MAZE GAME  |  CEN323  |  EMU8086       ',13,10,'$'
hdr3    DB '================================================',13,10,'$'
hdr4    DB '   Arrow Keys = Move        ESC = Quit         ',13,10,'$'
hdr5    DB '================================================',13,10,'$'
smoves  DB 'Moves: $'
sscore  DB '   Score: $'
snl     DB 13,10,'$'
swin1   DB '================================================',13,10,'$'
swin2   DB '       *** YOU WIN! MAZE COMPLETED! ***        ',13,10,'$'
swin3   DB '================================================',13,10,'$'
sany    DB '           Press ESC to exit...               ',13,10,'$'

.code

; ============================================================
; MAIN PROCEDURE
; ============================================================
main PROC
    mov ax, @data
    mov ds, ax

    ; Set video mode 3 (80x25 text) - clears screen
    mov ax, 0003h
    int 10h

    ; Draw screen for first time
    call redraw

; ---- Main Input Loop ----
input_loop:
    mov ah, 00h
    int 16h             ; BIOS keyboard: AH=scancode AL=ascii

    ; ESC to quit
    cmp al, 1Bh
    je  do_quit

    ; Arrow keys send AL=00h first
    cmp al, 00h
    jne input_loop      ; not an arrow key - ignore

    ; Up Arrow = scancode 48h
    cmp ah, 48h
    je  key_up

    ; Down Arrow = scancode 50h
    cmp ah, 50h
    je  key_down

    ; Left Arrow = scancode 4Bh
    cmp ah, 4Bh
    je  key_left

    ; Right Arrow = scancode 4Dh
    cmp ah, 4Dh
    je  key_right

    jmp input_loop

key_up:
    ; new position = (player_row - 1, player_col)
    mov al, player_row
    cmp al, 0           ; already at top?
    je  input_loop
    dec al
    mov new_row, al
    mov al, player_col
    mov new_col, al
    call do_move
    jmp input_loop

key_down:
    mov al, player_row
    inc al
    cmp al, ROWS
    jge input_loop      ; already at bottom?
    mov new_row, al
    mov al, player_col
    mov new_col, al
    call do_move
    jmp input_loop

key_left:
    mov al, player_col
    cmp al, 0
    je  input_loop
    dec al
    mov new_col, al
    mov al, player_row
    mov new_row, al
    call do_move
    jmp input_loop

key_right:
    mov al, player_col
    inc al
    cmp al, COLS
    jge input_loop
    mov new_col, al
    mov al, player_row
    mov new_row, al
    call do_move
    jmp input_loop

do_quit:
    mov ax, 4C00h
    int 21h
main ENDP

; ============================================================
; do_move PROCEDURE
; Reads new_row, new_col from memory
; Checks collision, updates player, calls redraw or win
; ============================================================
do_move PROC
    push ax
    push bx
    push dx
    push si

    ; Calculate index: index = new_row * COLS + new_col
    xor ax, ax
    mov al, new_row
    mov bl, COLS
    mul bl              ; AX = new_row * COLS
    xor bx, bx
    mov bl, new_col
    add ax, bx          ; AX = index into maze array
    mov si, ax

    ; Get maze character at new position
    mov al, maze[si]

    ; Collision detection: is it a wall?
    cmp al, '#'
    je  dm_blocked      ; YES - do not move

    ; Valid move - update player position
    mov bl, new_row
    mov player_row, bl
    mov bl, new_col
    mov player_col, bl

    ; Increment move counter
    inc moves

    ; Decrease score (minimum 0)
    cmp score, 0
    je  dm_noscore
    dec score
dm_noscore:

    ; Check win condition
    cmp al, 'E'
    je  dm_win

    ; Normal move - redraw screen
    call redraw
    jmp dm_done

dm_win:
    ; Player reached exit!
    call redraw
    call show_win
    ; Wait for ESC key
wait_esc:
    mov ah, 00h
    int 16h
    cmp al, 1Bh
    jne wait_esc
    ; Exit program
    pop si
    pop dx
    pop bx
    pop ax
    mov ax, 4C00h
    int 21h

dm_blocked:
    ; Wall - no movement, no redraw needed

dm_done:
    pop si
    pop dx
    pop bx
    pop ax
    ret
do_move ENDP

; ============================================================
; redraw PROCEDURE
; Clears screen then prints maze with player position
; Uses INT 21h / AH=09h for DOS string output
; Uses INT 21h / AH=02h for single char output
; ============================================================
redraw PROC
    push ax
    push bx
    push cx
    push dx
    push si

    ; Clear screen via BIOS video mode reset
    mov ax, 0003h
    int 10h

    ; Print header
    mov ah, 09h
    mov dx, OFFSET hdr1
    int 21h
    mov dx, OFFSET hdr2
    int 21h
    mov dx, OFFSET hdr3
    int 21h
    mov dx, OFFSET hdr4
    int 21h
    mov dx, OFFSET hdr5
    int 21h

    ; ---- Draw maze row by row ----
    mov cl, 0           ; CL = current row (0 to ROWS-1)

draw_row:
    cmp cl, ROWS
    jge draw_done       ; all rows printed

    mov bl, 0           ; BL = current col (0 to COLS-1)

draw_col:
    cmp bl, COLS
    jge draw_eol        ; end of this row

    ; ---- Check if player '@' is at (cl, bl) ----
    mov al, cl
    cmp al, player_row
    jne draw_maze_cell
    mov al, bl
    cmp al, player_col
    jne draw_maze_cell

    ; Print player character '@'
    mov ah, 02h
    mov dl, '@'
    int 21h
    jmp draw_next_col

draw_maze_cell:
    ; Get maze character: index = cl * COLS + bl
    push cx
    push bx
    xor ax, ax
    mov al, cl
    mov dl, COLS
    mul dl              ; AX = row * COLS
    xor bh, bh
    add al, bl
    adc ah, 0           ; AX = row*COLS + col
    mov si, ax
    mov dl, maze[si]    ; DL = maze character
    pop bx
    pop cx

    ; Print maze character
    mov ah, 02h
    int 21h

draw_next_col:
    inc bl
    jmp draw_col

draw_eol:
    ; New line after each row
    mov ah, 09h
    mov dx, OFFSET crlf
    int 21h
    inc cl
    jmp draw_row

draw_done:
    ; ---- Print stats ----
    mov ah, 09h
    mov dx, OFFSET hdr5
    int 21h

    ; Print "Moves: "
    mov dx, OFFSET smoves
    int 21h
    mov ax, moves
    call print_num

    ; Print "Score: "
    mov dx, OFFSET sscore
    int 21h
    mov ax, score
    call print_num

    mov dx, OFFSET snl
    int 21h

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
redraw ENDP

; ============================================================
; show_win PROCEDURE
; Displays victory message below the maze
; ============================================================
show_win PROC
    push ax
    push dx

    mov ah, 09h
    mov dx, OFFSET snl
    int 21h
    mov dx, OFFSET swin1
    int 21h
    mov dx, OFFSET swin2
    int 21h
    mov dx, OFFSET swin3
    int 21h
    mov dx, OFFSET sany
    int 21h

    pop dx
    pop ax
    ret
show_win ENDP

; ============================================================
; print_num PROCEDURE
; Input: AX = unsigned 16-bit number to print
; Uses stack to reverse digits, INT 21h AH=02h to print
; ============================================================
print_num PROC
    push ax
    push bx
    push cx
    push dx

    mov bx, 10          ; divisor
    mov cx, 0           ; digit count

    ; Push digits onto stack (least significant first)
push_digits:
    xor dx, dx
    div bx              ; AX = quotient, DX = remainder
    push dx             ; save digit
    inc cx
    cmp ax, 0
    jne push_digits

    ; Pop and print digits (most significant first)
pop_digits:
    pop dx
    add dl, '0'         ; convert to ASCII
    mov ah, 02h
    int 21h             ; print character
    loop pop_digits

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num ENDP

END main

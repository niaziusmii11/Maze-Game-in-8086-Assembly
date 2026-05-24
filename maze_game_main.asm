; ============================================================
;   MAZE GAME - 8086 Assembly | CEN323 | emu8086
;   Arrow Keys = Move    ESC = Quit
;
;   RANDOM MAZE FEATURE:
;   - 5 different mazes pre-generated and verified
;   - Timer port (40h) used to pick random maze each run
;   - Outer walls always same
;   - Start S = (row1,col1)  End E = (row9,col13) always same
;   - All 5 mazes have confirmed solution paths
; ============================================================
.model small
.stack 200h

.data

ROWS       EQU 11
COLS       EQU 15
MAZE_SIZE  EQU 165      ; 11 * 15 = 165 bytes per maze
SCREEN_TOP EQU 4

; ============================================================
; 5 pre-verified mazes (each 165 bytes)
; Outer walls same, S=(1,1), E=(9,13) same in all
; Inner paths completely different
; ============================================================

; --- MAZE 1 (seed=42) path=49 steps ---
maze1 DB '#','#','#','#','#','#','#','#','#','#','#','#','#','#','#'
      DB '#','S','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#'
      DB '#',' ','#',' ','#','#','#','#','#',' ','#','#','#',' ','#'
      DB '#',' ','#',' ',' ',' ',' ',' ','#',' ','#',' ',' ',' ','#'
      DB '#',' ','#',' ','#','#','#','#','#',' ','#','#','#',' ','#'
      DB '#',' ','#',' ','#',' ',' ',' ','#',' ',' ',' ','#',' ','#'
      DB '#',' ','#','#','#',' ','#',' ','#','#','#',' ','#',' ','#'
      DB '#',' ','#',' ',' ',' ','#',' ','#',' ',' ',' ','#',' ','#'
      DB '#',' ','#',' ','#','#','#',' ','#',' ','#','#','#',' ','#'
      DB '#',' ',' ',' ','#',' ',' ',' ',' ',' ','#',' ',' ','E','#'
      DB '#','#','#','#','#','#','#','#','#','#','#','#','#','#','#'

; --- MAZE 2 (seed=137) path=29 steps ---
maze2 DB '#','#','#','#','#','#','#','#','#','#','#','#','#','#','#'
      DB '#','S','#',' ',' ',' ','#',' ',' ',' ',' ',' ',' ',' ','#'
      DB '#',' ','#','#','#',' ','#',' ','#','#','#','#','#',' ','#'
      DB '#',' ',' ',' ','#',' ',' ',' ','#',' ',' ',' ','#',' ','#'
      DB '#','#','#',' ','#','#','#','#','#',' ','#',' ','#',' ','#'
      DB '#',' ','#',' ',' ',' ',' ',' ',' ',' ','#',' ',' ',' ','#'
      DB '#',' ','#','#','#','#','#','#','#','#','#','#','#',' ','#'
      DB '#',' ','#',' ',' ',' ',' ',' ',' ',' ','#',' ',' ',' ','#'
      DB '#',' ','#',' ','#','#','#','#','#',' ','#',' ','#','#','#'
      DB '#',' ',' ',' ',' ',' ',' ',' ','#',' ',' ',' ',' ','E','#'
      DB '#','#','#','#','#','#','#','#','#','#','#','#','#','#','#'

; --- MAZE 3 (seed=255) path=25 steps ---
maze3 DB '#','#','#','#','#','#','#','#','#','#','#','#','#','#','#'
      DB '#','S','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#'
      DB '#',' ','#','#','#','#','#',' ','#',' ','#','#','#','#','#'
      DB '#',' ',' ',' ',' ',' ','#',' ','#',' ',' ',' ',' ',' ','#'
      DB '#','#','#','#','#',' ','#','#','#','#','#','#','#',' ','#'
      DB '#',' ',' ',' ','#',' ',' ',' ',' ',' ',' ',' ',' ',' ','#'
      DB '#',' ','#','#','#','#','#','#','#','#','#','#','#',' ','#'
      DB '#',' ',' ',' ','#',' ',' ',' ',' ',' ','#',' ',' ',' ','#'
      DB '#',' ','#',' ','#',' ','#','#','#',' ','#',' ','#','#','#'
      DB '#',' ','#',' ',' ',' ',' ',' ','#',' ',' ',' ',' ','E','#'
      DB '#','#','#','#','#','#','#','#','#','#','#','#','#','#','#'

; --- MAZE 4 (seed=999) path=29 steps ---
maze4 DB '#','#','#','#','#','#','#','#','#','#','#','#','#','#','#'
      DB '#','S','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#'
      DB '#',' ','#',' ','#','#','#','#','#','#','#','#','#','#','#'
      DB '#',' ','#',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','#'
      DB '#',' ','#',' ','#','#','#','#','#','#','#','#','#',' ','#'
      DB '#',' ','#',' ',' ',' ',' ',' ',' ',' ',' ',' ','#',' ','#'
      DB '#',' ','#',' ','#','#','#','#','#',' ','#','#','#',' ','#'
      DB '#',' ','#',' ','#',' ',' ',' ','#',' ','#',' ',' ',' ','#'
      DB '#',' ','#','#','#',' ','#',' ','#','#','#',' ','#',' ','#'
      DB '#',' ',' ',' ',' ',' ','#',' ',' ',' ',' ',' ','#','E','#'
      DB '#','#','#','#','#','#','#','#','#','#','#','#','#','#','#'

; --- MAZE 5 (seed=1234) path=45 steps ---
maze5 DB '#','#','#','#','#','#','#','#','#','#','#','#','#','#','#'
      DB '#','S','#',' ',' ',' ',' ',' ',' ',' ','#',' ',' ',' ','#'
      DB '#',' ','#',' ','#','#','#','#','#',' ','#',' ','#','#','#'
      DB '#',' ','#',' ',' ',' ','#',' ',' ',' ','#',' ',' ',' ','#'
      DB '#',' ','#',' ','#',' ','#',' ','#','#','#',' ','#',' ','#'
      DB '#',' ','#',' ','#',' ','#',' ','#',' ',' ',' ','#',' ','#'
      DB '#',' ','#',' ','#',' ','#',' ','#',' ','#','#','#',' ','#'
      DB '#',' ','#',' ','#',' ','#',' ','#',' ',' ',' ','#',' ','#'
      DB '#',' ','#','#','#',' ','#',' ','#','#','#','#','#',' ','#'
      DB '#',' ',' ',' ',' ',' ','#',' ',' ',' ',' ',' ',' ','E','#'
      DB '#','#','#','#','#','#','#','#','#','#','#','#','#','#','#'

; ---- Maze pointer table (offsets of each maze) ----
; We store offset of each maze - will use SI to point to chosen one
maze_table DW OFFSET maze1
           DW OFFSET maze2
           DW OFFSET maze3
           DW OFFSET maze4
           DW OFFSET maze5

; ---- Active maze pointer (which maze is currently loaded) ----
active_maze DW OFFSET maze1   ; default, overwritten at start

player_row  DB 1
player_col  DB 1
new_r       DB 0
new_c       DB 0
moves       DW 0

crlf    DB 13,10,'$'
hdr1    DB '===== MAZE GAME - CEN323 8086 =====',13,10,'$'
hdr2    DB '  Arrow Keys = Move    ESC = Quit  ',13,10,'$'
hdr3    DB '===================================',13,10,'$'
smaze   DB 'Maze #$'
smoves  DB '  Moves: $'
swin    DB '  *** YOU WIN! ***  $'
sesc    DB '  Press ESC to exit$'
maze_num DB '1'             ; which maze number (for display)

.code

; ============================================================
; goto_rc: move cursor to row DH, col DL
; ============================================================
goto_rc PROC
    push ax
    push bx
    mov ah, 02h
    mov bh, 00h
    int 10h
    pop bx
    pop ax
    ret
goto_rc ENDP

; ============================================================
; print_char_at: print char AL at screen row DH col DL
; ============================================================
print_char_at PROC
    push ax
    push bx
    push cx
    push dx
    call goto_rc
    mov ah, 02h
    mov dl, al
    int 21h
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_char_at ENDP

; ============================================================
; get_maze_char: returns active_maze[CL][CH] in AL
; Uses active_maze pointer to support random maze selection
; ============================================================
get_maze_char PROC
    push bx
    push dx
    push si

    ; index = row * COLS + col
    xor ax, ax
    mov al, cl          ; row
    mov bl, COLS
    mul bl              ; ax = row * 15
    xor bx, bx
    mov bl, ch          ; col
    add ax, bx          ; ax = final index

    ; add to base address of active maze
    mov si, active_maze ; SI = base address of chosen maze
    add si, ax          ; SI = base + index
    mov al, [si]        ; AL = character at that cell

    pop si
    pop dx
    pop bx
    ret
get_maze_char ENDP

; ============================================================
; pick_random_maze: reads timer, picks 1 of 5 mazes
; Uses IN AL, 40h to read 8253 timer channel 0
; Timer gives different value each run = random seed
; ============================================================
pick_random_maze PROC
    push ax
    push bx
    push dx

    ; Read hardware timer port 40h (8253 PIT channel 0)
    ; This gives a changing byte value = our random number
    in  al, 40h         ; read low byte of timer counter
    xor ah, ah          ; clear AH
    mov bl, 5           ; we have 5 mazes
    div bl              ; AH = AL mod 5 (remainder = 0..4)
    xor ah, ah
    mov al, ah          ; AL = 0,1,2,3 or 4

    ; store display digit
    add al, '1'         ; convert to '1'..'5'
    mov maze_num, al
    sub al, '1'         ; back to 0..4

    ; get maze offset from table
    xor bx, bx
    mov bl, al
    shl bx, 1           ; BX = index * 2 (each entry is a WORD)
    mov ax, maze_table[bx]  ; AX = offset of chosen maze
    mov active_maze, ax     ; save it

    pop dx
    pop bx
    pop ax
    ret
pick_random_maze ENDP

; ============================================================
; MAIN
; ============================================================
main PROC
    mov ax, @data
    mov ds, ax

    ; clear screen
    mov ax, 0003h
    int 10h

    ; pick random maze using timer
    call pick_random_maze

    ; reset player and moves
    mov player_row, 1
    mov player_col, 1
    mov moves, 0

    ; draw everything
    call draw_screen_once

game_loop:
    mov ah, 00h
    int 16h

    cmp al, 1Bh
    je  do_exit

    cmp al, 00h
    jne game_loop

    ; UP arrow = scancode 48h
    cmp ah, 48h
    jne chk_dn
    mov al, player_row
    cmp al, 0
    je  game_loop
    dec al
    mov new_r, al
    mov al, player_col
    mov new_c, al
    call do_move
    jmp game_loop

chk_dn:
    ; DOWN arrow = scancode 50h
    cmp ah, 50h
    jne chk_lt
    mov al, player_row
    inc al
    cmp al, ROWS
    jge game_loop
    mov new_r, al
    mov al, player_col
    mov new_c, al
    call do_move
    jmp game_loop

chk_lt:
    ; LEFT arrow = scancode 4Bh
    cmp ah, 4Bh
    jne chk_rt
    mov al, player_col
    cmp al, 0
    je  game_loop
    dec al
    mov new_c, al
    mov al, player_row
    mov new_r, al
    call do_move
    jmp game_loop

chk_rt:
    ; RIGHT arrow = scancode 4Dh
    cmp ah, 4Dh
    jne game_loop
    mov al, player_col
    inc al
    cmp al, COLS
    jge game_loop
    mov new_c, al
    mov al, player_row
    mov new_r, al
    call do_move
    jmp game_loop

do_exit:
    mov ax, 4C00h
    int 21h
main ENDP

; ============================================================
; do_move: validate move, update screen, check win
; ============================================================
do_move PROC
    push ax
    push cx
    push dx

    ; check new cell
    mov cl, new_r
    mov ch, new_c
    call get_maze_char
    cmp al, '#'
    je  dm_done

    ; erase old player - restore original maze char
    mov cl, player_row
    mov ch, player_col
    call get_maze_char
    mov dh, SCREEN_TOP
    add dh, player_row
    mov dl, player_col
    call print_char_at

    ; update player position
    mov al, new_r
    mov player_row, al
    mov al, new_c
    mov player_col, al
    inc moves

    ; draw @ at new position
    mov al, '@'
    mov dh, SCREEN_TOP
    add dh, player_row
    mov dl, player_col
    call print_char_at

    ; update moves counter
    call update_moves

    ; check win
    mov cl, player_row
    mov ch, player_col
    call get_maze_char
    cmp al, 'E'
    je  dm_win

dm_done:
    pop dx
    pop cx
    pop ax
    ret

dm_win:
    mov dh, SCREEN_TOP + ROWS + 1
    mov dl, 00h
    call goto_rc
    mov ah, 09h
    mov dx, OFFSET swin
    int 21h
    mov dh, SCREEN_TOP + ROWS + 2
    mov dl, 00h
    call goto_rc
    mov dx, OFFSET sesc
    int 21h
wait_esc:
    mov ah, 00h
    int 16h
    cmp al, 1Bh
    jne wait_esc
    pop dx
    pop cx
    pop ax
    mov ax, 4C00h
    int 21h
do_move ENDP

; ============================================================
; update_moves: refresh move counter on screen
; ============================================================
update_moves PROC
    push ax
    push bx
    push cx
    push dx

    mov dh, SCREEN_TOP + ROWS
    mov dl, 00h
    call goto_rc

    ; print "Maze #X  Moves: N"
    mov ah, 09h
    mov dx, OFFSET smaze
    int 21h
    mov ah, 02h
    mov dl, maze_num
    int 21h
    mov ah, 09h
    mov dx, OFFSET smoves
    int 21h

    ; print moves number
    mov ax, moves
    mov bx, 10
    mov cx, 0
um_push:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne um_push
um_pop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop um_pop

    ; space to clear old digit
    mov ah, 02h
    mov dl, ' '
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
update_moves ENDP

; ============================================================
; draw_screen_once: draw header + maze + stats at startup
; ============================================================
draw_screen_once PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov dh, 00h
    mov dl, 00h
    call goto_rc

    mov ah, 09h
    mov dx, OFFSET hdr1
    int 21h
    mov dx, OFFSET hdr2
    int 21h
    mov dx, OFFSET hdr3
    int 21h
    mov dx, OFFSET crlf
    int 21h

    ; draw maze row by row
    xor cx, cx          ; cl = row

ds_row:
    cmp cl, ROWS
    jge ds_after
    xor bx, bx          ; bl = col

ds_col:
    cmp bl, COLS
    jge ds_eol

    ; player at this cell?
    mov al, cl
    cmp al, player_row
    jne ds_cell
    mov al, bl
    cmp al, player_col
    jne ds_cell

    mov ah, 02h
    mov dl, '@'
    int 21h
    jmp ds_nc

ds_cell:
    mov ch, bl
    call get_maze_char  ; AL = maze char
    mov dl, al
    mov ah, 02h
    int 21h

ds_nc:
    inc bl
    xor ch, ch
    jmp ds_col

ds_eol:
    mov ah, 09h
    mov dx, OFFSET crlf
    int 21h
    inc cl
    jmp ds_row

ds_after:
    ; stats line
    mov ah, 09h
    mov dx, OFFSET smaze
    int 21h
    mov ah, 02h
    mov dl, maze_num    ; show which maze
    int 21h
    mov ah, 09h
    mov dx, OFFSET smoves
    int 21h
    mov ah, 02h
    mov dl, '0'
    int 21h

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_screen_once ENDP

END main

# CEN323\_G??\_MazeGame

## Grid-Based Maze Game | 8086 Assembly Language

**Bahria University | CEN323 - Computer Organization \& Assembly Language**

\---

## 👥 Group Members \& Contributions

|Name|Reg. No.|GitHub|Module(s) Owned|
|-|-|-|-|
|Muhammad Usman Khan|01-135232-072|[@niaziusmii11](https://github.com/niaziusmii11)|Movement logic, collision detection, input handler, score system|
|Muhammad Talha|01-135232-069|(TalhaAwan8)|Rendering (redraw), print\_num, show\_win, maze data|

\---

## 🎮 About the Project

A fully interactive maze game implemented in **8086 Assembly Language** running on **emu8086**. The player navigates `@` through an 11×15 grid maze using arrow keys, avoiding walls and reaching the exit `E`.

```
================================================
        MAZE GAME  |  CEN323  |  EMU8086
================================================
   Arrow Keys = Move        ESC = Quit
================================================
###############
#@  #   #     #
### # # ### # #
#     #   #   #
# ####### # ###
# #     #   # #
# # ### ### # #
#   #     #   #
### # ### ### #
#     #      E#
###############
================================================
Moves: 0   Score: 500
```

\---

## 🕹️ Controls

|Key|Action|
|-|-|
|⬆️ Arrow Up|Move Up|
|⬇️ Arrow Down|Move Down|
|⬅️ Arrow Left|Move Left|
|➡️ Arrow Right|Move Right|
|ESC|Quit Game|

\---

## 🚀 How to Run

1. Download `maze\_game.asm`
2. Open **emu8086**
3. Click **File → Open** → select `maze\_game.asm`
4. Click **Emulate**
5. Click **Run** (F5)
6. Click on the emulator screen window to give it focus
7. Use **Arrow Keys** to play

\---

## 🛠️ Assembly Concepts Used (12 Concepts)

|#|Concept|Where Used|
|-|-|-|
|1|Registers (AX,BX,CX,DX,SI)|Throughout all procedures|
|2|Procedures (PROC/ENDP)|main, do\_move, redraw, print\_num, show\_win|
|3|Conditional Jumps|JE, JNE, JGE, JA in collision \& input|
|4|Loops|draw\_row/draw\_col loops in redraw|
|5|Arrays / Memory Access|maze\[si] - flat byte array|
|6|Stack (PUSH/POP)|Every procedure saves/restores registers|
|7|Arithmetic (MUL,INC,DEC)|2D index: row×COLS+col in do\_move|
|8|INT 10h (BIOS Video)|Screen clear, video mode set|
|9|INT 16h (BIOS Keyboard)|Arrow key detection|
|10|INT 21h (DOS I/O)|String and char output|
|11|Data Segment Variables|player\_row, player\_col, moves, score|
|12|Modular Design|Separate proc for each function|

\---

## 📁 File Structure

```
CEN323\_G??\_MazeGame/
├── maze\_game.asm     ← Main source file (run this in emu8086)
└── README.md         ← This file
```

\---

## 📚 References

* INT 10h: http://www.ctyme.com/intr/int-10.htm
* INT 16h: http://www.ctyme.com/intr/int-16.htm
* INT 21h: http://www.ctyme.com/intr/int-21.htm
* emu8086: https://emu8086-microprocessor-emulator.en.softonic.com/

> \*\*AI Disclosure:\*\* Claude AI was used as a programming assistant. All code was reviewed and understood by both members. Disclosed as per Section 7.1 of the Phase 2 specification.


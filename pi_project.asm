; PI_project, a Monte-Carlo pi calculator written in 8bit-microchip-Assembly
; Copyright (C) 2010 Thomas Bertani <sylar@anche.no>
; portions Copyright (C) 2010 Giacomo Mariani
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License, version 3, as
; published by the Free Software Foundation.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA



list p=16F628A
#include p16f628A.inc



I EQU 0x20
J EQU I+1
_I EQU J+1
_J EQU _I+1
__I EQU _J+1
__J EQU __I+1

TMP0 EQU __J+1 ; riservato per le funzioni
TMP1 EQU TMP0+1
TMP2 EQU TMP1+1

_RANDOM EQU TMP2+1
RANDOM EQU _RANDOM+1
RAND_HI EQU RANDOM+1
RAND_LO EQU RAND_HI+1

N_max EQU RAND_LO+1
n_max EQU N_max+1
n_punti EQU n_max+1

i_y EQU n_punti+1
n EQU i_y+1
X EQU n+1
x EQU X+1
Y EQU x+1
y EQU Y+1
a EQU y+1
b_ EQU a+1
c EQU b_+1
d EQU c+1
e EQU d+1
f EQU e+1
g EQU f+1
n_slice EQU g+1
i EQU n_slice+1
r EQU i+1

DH EQU r+1
DL EQU DH+1
VH EQU DL+1
VL EQU VH+1
QH EQU VL+1
QL EQU QH+1
CL EQU QL+1
FL EQU CL+1

RES_ EQU FL+1
RES_HI EQU RES_+1
RES_LO EQU RES_HI+1

PRODHI EQU RES_LO+1
PRODLO EQU PRODHI+1
COUNT EQU PRODLO+1


ORG 0x0000

goto init

#include functions.inc

var_init:
  movlw 0x07
  movwf N_max
  movlw 0x04
  movwf n_max
  movf n_max, 0
  movwf I
  movlw 0x02
  movwf J
  call div
  movwf y ; y = n_max/2
  movlw 0x0F
  movwf n_punti
  movlw 0x50
  movwf _RANDOM
  return

init:
  bsf STATUS, 5
  bcf PCON, 3 ; setta INTOSC a 48 KHz
  bcf STATUS, 5
  bsf INTCON,T0IE ;;
  bsf INTCON,GIE ;;
  call var_init
  clrf n
  clrf i_y
computation_loop:
    incf i_y ; i_y+= 1
    movf i_y, 0
    movwf I
    movf N_max, 0
    movwf TMP0
    incf TMP0
    movf TMP0, 0
    movwf J
    call is_min ; controlla se i_y <= N_max
    movwf TMP0
    btfss TMP0, 0
    goto result
    goto pi_slice
pi_slice:
    movf i_y, 0
    movwf Y
    clrf n_slice
    clrf i
pi_slice_loop:
    movf i, 0
    movwf I
    movf n_punti, 0
    movwf J
    call is_min ; controlla se i < n_punti
    movwf TMP0
    btfss TMP0, 0
    goto pi_slice_end
    ;;
    movlw 0x01
    movwf I
    movf N_max, 0
    movwf J
    call rand
    movwf X ; X = randint(1, N_max)
    ;===============================;
    movf X, 0
    movwf I
    movwf J
    call mult
    movwf TMP1
    movf Y, 0
    movwf I
    movwf J
    call mult
    movwf TMP2
    movf TMP1, 0
    movwf I
    movwf TMP2
    movwf J
    call add
    movwf TMP1 ; TMP1 = X**2+Y**2
    movf N_max, 0
    movwf I
    movwf J
    call mult
    movwf I
    movlw 0x01
    movwf J
    call add
    movwf TMP2 ; TMP2 = N_max**2+1
    movf TMP1, 0
    movwf I
    movf TMP2, 0
    movwf J
    call is_min ; controlla se X**2+Y**2 <= N_max**2
    movwf TMP0
    btfss TMP0, 0
    goto next_check_1
    incf n_slice
    goto pi_slice_addr0
next_check_1:
    movf N_max, 0
    movwf I
    movwf J
    call mult
    movwf TMP1 ; TMP1 = N_max**2
    movf X, 0
    movwf TMP0
    decf TMP0
    movf TMP0, 0
    movwf I
    movwf J
    call mult ; W = (X-1)**2
    movwf TMP2
    movf Y, 0
    movwf TMP0
    decf TMP0
    movf TMP0, 0
    movwf I
    movwf J
    call mult
    movwf I
    movf TMP2, 0
    movwf J
    call add
    movwf TMP2 ; TMP2 = (X-1)**2+(Y-1)**2
    movwf I
    movf TMP1, 0
    movwf J
    call is_min
    movwf TMP0
    btfss TMP0, 0
    goto pi_slice_addr0
    goto next_check_2
next_check_2:
    movlw 0x01
    movwf I
    movf n_max, 0
    movwf J
    call rand
    movwf x ; x = randint(1, n_max)
    movf X, 0
    movwf TMP0
    decf TMP0
    movf TMP0, 0
    movwf I
    movwf J
    call mult
    movwf TMP1
    movf Y, 0
    movwf I
    movwf J
    call mult
    movwf I
    movf TMP1, 0
    movwf J
    call add
    movwf TMP1 ; TMP1 = (X-1)**2+Y**2
    movf N_max, 0
    movwf I
    movwf J
    call mult
    movwf I
    movf Y, 0
    movwf J
    call add
    movwf TMP2 ; TMP2 = N_max**2+Y
    movf TMP1, 0
    movwf I
    movf TMP2, 0
    movwf J
    call is_min
    movwf TMP0
    btfss TMP0, 0
    goto pi_slice_addr1
    goto pi_slice_addr2
pi_slice_addr1:
    movf x, 0
    movwf I
    movwf J
    call mult
    movwf TMP1
    movf n_max, 0
    movwf I
    movwf J
    call mult
    movwf I
    movf N_max, 0
    movwf J
    call mult
    movwf TMP2
    movf TMP1, 0
    movwf I
    movf TMP2, 0
    movwf J
    call add
    movwf a ; a = x**2+N_max*n_max**2
    movf N_max, 0
    movwf I
    movwf J
    call mult
    movwf I
    movf Y, 0
    movwf J
    call add
    movwf I
    movf N_max
    movwf J
    call add
    movwf TMP1 ; TMP1 = N_max**2+Y+N_max
    movf X, 0
    movwf TMP2
    decf TMP2
    movf TMP2, 0
    movwf I
    movwf J
    call mult
    movwf J
    movf TMP1, 0
    movwf I
    call sub
    movwf TMP1
    movf Y, 0
    movwf I
    movwf J
    call mult
    movwf J
    movf TMP1, 0
    movwf I
    call sub
    movwf c ; c = N_max**2-(X-1)**2-Y**2+Y+N_max
    goto pi_slice_addr3
pi_slice_addr2:
    movf x, 0
    movwf I
    movwf J
    call mult
    movwf a ; a = x**2
    movf N_max, 0
    movwf I
    movwf J
    call mult
    movwf I
    movf Y, 0
    movwf J
    call add
    movwf TMP1 ; TMP1 = N_max**2+Y
    movf X, 0
    movwf TMP2
    decf TMP2
    movf TMP2, 0
    movwf I
    movwf J
    call mult
    movwf J
    movf TMP1, 0
    movwf I
    call sub
    movwf TMP1
    movf Y, 0
    movwf I
    movwf J
    call mult
    movwf J
    movf TMP1, 0
    movwf I
    call sub
    movwf c ; c = N_max**2-(X-1)**2-Y**2+Y
    goto pi_slice_addr3
pi_slice_addr3:
    movf X, 0
    movwf TMP0
    decf TMP0
    movf TMP0, 0
    movwf I
    movlw 0x02
    movwf J
    call mult
    movwf I
    movf x, 0
    movwf J
    call mult
    movwf I
    movf n_max, 0
    movwf J
    call mult
    movwf b_ ; b_ = x*(X-1)*2*n_max
    movf n_max, 0
    movwf I
    movwf J
    call mult
    movwf d ; d = n_max**2
    movf d, 0
    movwf I
    movf c, 0
    movwf J
    call mult
    movwf e ; e = c*d
    movf d, 0
    movwf I
    movlw 0x04
    movwf J
    call div
    movwf J
    movf e, 0
    movwf I
    call sub
    movwf f ; f = e-d/4
    movf a, 0
    movwf I
    movf b_, 0
    movwf J
    call add
    movwf g ; g = a+b_
    movf f, 0
    movwf TMP1
    incf TMP1
    movf TMP1, 0
    movwf J
    movf g, 0
    movwf I
    call is_min ; controlla se g <= f
    movwf TMP0
    btfss TMP0, 0
    nop
    incf n_slice
    ;===============================;
pi_slice_addr0:
    incf i
    goto pi_slice_loop
pi_slice_end:
    movf n_slice, 0
    movwf I
    movf n, 0
    movwf J
    call add
    movwf n ; n += n_slice
    goto computation_loop
result:
  movf n, 0
  movwf PRODLO
  movlw 0x0A
  call MPY8X8
;;;;
  movf PRODHI, 0
  movwf DH
  movf PRODLO, 0
  movwf DL
  clrf VH
  movlw 0x1A ; 26
  movwf VL
  call DIV16
  movf QL, 0 ; int(PI)
  movwf RES_
  clrf DH
  movwf DL
  clrf VH
  movlw 0x0A
  movwf VL
  call DIV16
  movf QL, 0
  movwf RES_HI
  movf DL, 0
  movwf RES_LO
end_:
  bsf STATUS, 5
  clrf TRISA
  clrf TRISB
  bcf STATUS, 5
result_printing:
  movf RES_HI, 0
  movwf I
  call to_led
  bcf PORTA, 1
  movwf PORTB
  bsf PORTB, 0 ;forza il "."
  bsf PORTA, 0
  movf RES_LO, 0
  movwf I
  call to_led
  bcf PORTA, 0
  movwf PORTB
  bsf PORTA, 1
  goto result_printing
  sleep
  movf RES_, 0
__end:
END

MPY8X8:

	CLRF PRODHI

	CLRF COUNT
	BSF COUNT,3

	RRF PRODLO,F

LOOP:

	SKPNC
	ADDWF PRODHI,F
	
	RRF PRODHI,F
	RRF PRODLO,F

	DECFSZ COUNT
	GOTO LOOP
return
;;;;;;;;;;;
;-----------------------------------------------------
; Divisione 16 bit intera senza segno
; Operazione: QH:QL=DH:DL/VH:VL  DH:DL=resto
; IN:  DH:DL=dividendo  VH:VL=divisore
; OUT: QH:QL=quoziente  DH:DL=resto
; CL = contatore di ciclo  FL = salvataggio flag
;-----------------------------------------------------
DIV16       CLRF        QH          ;Azzera quoziente
            CLRF        QL
            CLRF        CL          ;Azzera contatore di ciclo
DIV16_2     INCF        CL,F        ;CL=CL+1
            BTFSC       VH,7        ;Se bit 7 di VH=0 skip
            GOTO        DIV16_3     ;altrimenti vai a DIV16_3
            BCF         STATUS,C    ;Azzera carry
            RLF         VL,F        ;Ruota divisore a sinistra
            RLF         VH,F
            GOTO        DIV16_2     ;Vai a DIV16_2
DIV16_3     CALL        SUB16       ;Chiama sottraz. DH:DL-VH:VL
            RLF         QL,F        ;Ruota carry a destra nel quoziente
            RLF         QH,F
            BTFSS       QL,0        ;Se non overflow skip
            CALL        RESTORING   ;altrimenti chiama somma DH:DL+VH:VL
            BCF         STATUS,C    ;Azzera carry
            RRF         VH,F        ;Ruota divisore a destra
            RRF         VL,F
            DECFSZ      CL,F        ;Decrementa contat.ciclo, skip se 0
            GOTO        DIV16_3     ;altrimenti vai a DIV16_3
            RETURN                  ;Fine subroutine
;-----------------------------------------------------
; DH:DL = DH:DL - VH:VL  (con regolazione corretta flag C)
; FL = salvataggio intermedio flag C
;-----------------------------------------------------
SUB16       BSF         FL,4        ;Imposta a 1 il bit 4 di FL 
            MOVF        VL,W        ;W=parte bassa divisore
            SUBWF       DL,F        ;ao sottrae a parte bassa dividendo
            BTFSC       STATUS,C    ;Se overflow skip
            GOTO        SUB16_2     ;altrimenti vai a SUB16_2
            MOVLW       1
            SUBWF       DH,F        ;Sottrae 1 a parte alta dividendo
            SWAPF       STATUS,W    ;Salva i flag in FL
            MOVWF       FL
SUB16_2     MOVF        VH,W        ;W=parte alta divisore
            SUBWF       DH,F        ;la sottrae a parte alta dividendo
            BTFSS       FL,4        ;Controlla bit 4 di FL, se 1 skip
            BCF         STATUS,C    ;altrimenti resetta carry
            RETURN
;-----------------------------------------------------
; DH:DL = DH:DL + VH:VL  (senza regolazione flag C)
;-----------------------------------------------------
RESTORING   MOVF        VL,W        ;W=parte bassa divisore
            ADDWF       DL,F        ;la somma a parte bassa dividendo
            BTFSC       STATUS,C    ;Se non overflow skip
            INCF        DH,F        ;altrimenti incrementa parte alta dividendo
            MOVF        VH,W        ;W=parte alta divisore
            ADDWF       DH,F        ;la somma a parte alta dividendo
            RETURN
;-----------------------------------------------------
;;;;;;;;;;;

;==========================

to_led:
;    1
;    _
; 2 |_| (3) 4
; 5 |_| 7     . 8
;    6
  movlw 0x0A
  movwf J
  call is_min
  movwf TMP0
  btfss TMP0, 0
  retlw 0xDE
  movf I, 0
  addwf PCL, 1
  retlw 0xDE
  retlw 0x12
  retlw 0xBC
  retlw 0xB6
  retlw 0x72
  retlw 0xE6
  retlw 0xEE
  retlw 0x92
  retlw 0xFE
  retlw 0xF6

is_min: ; I < J ? W = 1 : W = 0
  movf J, 0
  subwf I, 0
  btfss STATUS, C
  goto is_min_y
  goto is_min_f
is_min_y:
  movlw 0x01
  return
is_min_f:
  movlw 0x00
  return
add: ;W = I + J
  movf I, 0
  movwf TMP0
  movf J, 0
  addwf TMP0, 0
  return

sub: ;W = I - J
  movf I, 0
  movwf TMP0
  movf J, 0
  subwf TMP0, 0
  return

mult: ;W = I * J
  clrw
  movf J, 0
  movwf _J
multiplication_loop:
    addwf I, 0
    decfsz _J, 1
    goto multiplication_loop
  return

div: ;W = I / J
  clrf TMP0
  movf I, 0
  movwf _I
  movf J, 0
division_loop:
    subwf _I, 1
    btfss STATUS, C
    goto div_end
    btfsc STATUS, Z
    goto div_end_p
    incf TMP0
    goto division_loop
div_end_p:
  incf TMP0
div_end:
  movf TMP0, 0
  return

rand: ;W = randint(I, J)
  RLF     _RANDOM,W
  RLF     _RANDOM,W
  BTFSC   _RANDOM,4
  XORLW   1
  BTFSC   _RANDOM,5
  XORLW   1
  BTFSC   _RANDOM,3
  XORLW   1
  MOVWF   _RANDOM
  movwf RANDOM
  movf J, 0
  movwf __J
  movf I, 0
  movwf __I
  movf J, 0
  movwf _J
  movf I, 0
  subwf _J, 0
  movwf TMP0 ;TMP0 = J - I
  movlw 0xFF
  movwf I
  movf TMP0, 0
  movwf J
  call div
  movwf TMP0 ;TMP0 = 0xFF / TMP0
  movf RANDOM, 0
  movwf I
  movf TMP0, 0
  movwf J
  call div
  movwf RANDOM ;RANDOM = RANDOM / TMP0
  movf __I, 0
  movwf I
  movf RANDOM, 0
  movwf J
  call add
  movwf RANDOM ;RANDOM += I
  incf RANDOM
  movf RANDOM, 0
  RETURN


;==========================


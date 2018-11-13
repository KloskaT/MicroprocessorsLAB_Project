#include p18f87k22.inc
    
    global Pad_Setup, Pad_Read
    extern  LCD_clear, Input_store
    
acs0    udata_acs   ; named variables in access ram
PAD_cnt_l   res 1   ; reserve 1 byte for variable PAD_cnt_l
PAD_cnt_h   res 1   ; reserve 1 byte for variable PAD_cnt_h
PAD_cnt_ms  res 1   ; reserve 1 byte for ms counter
PAD_tmp	    res 1   ; reserve 1 byte for temporary use
PAD_counter res 1   ; reserve 1 byte for counting through nessage
pad_row res 1
pad_column res 1
pad_final res 1

pad	    code

Pad_Setup
    banksel PADCFG1
    bsf	    PADCFG1,REPU, BANKED
    clrf    LATH
    movlw   0x0F
    movwf   TRISH, A
    movlw   .10
    call    PAD_delay_x4us
    return
    
Pad_Read
    movlw   0x0F
    movwf   TRISH, A
    movlw   .10
    call    PAD_delay_x4us
    movff   PORTH, pad_row
    movlw   0xF0
    movwf   TRISH, A
    movlw   .10
    call    PAD_delay_x4us
    movff   PORTH, pad_column
    movf    pad_row,W
    iorwf   pad_column, W
    movwf   pad_final
 
Pad_Check
    movlw   b'11101110'		    
    cpfseq  pad_final			
    retlw   0x01

    call    Input_store
    call    sampling_delay
    
    movlw   b'11111111'		    
    cpfseq  pad_final
    bra	    Pad_Read
    retlw   0xFF
 
    
PAD_delay_x4us			; delay given in chunks of 4 microsecond in W
    movwf	PAD_cnt_l	; now need to multiply by 16
    swapf	PAD_cnt_l,F	; swap nibbles
    movlw	0x0f	    
    andwf	PAD_cnt_l,W	; move low nibble to W
    movwf	PAD_cnt_h	; then to PAD_cnt_h
    movlw	0xf0	    
    andwf	PAD_cnt_l,F	; keep high nibble in PAD_cnt_l
    call	PAD_delay
    return

PAD_delay			; delay routine	4 instruction loop == 250ns	    
    movlw 	0x00		; W=0
PADlp1	
    decf 	PAD_cnt_l,F	; no carry when 0x00 -> 0xff
    subwfb 	PAD_cnt_h,F	; no carry when 0x00 -> 0xff
    bc 	PADlp1			; carry, then loop again
    return			; carry reset so return
    
sampling_delay
    
    end
	LIST	P=16F716
	INCLUDE	P16F716.INC
Volume_Data	EQU	0x28
	ORG	0x00
;初始化
;读数据

ReadEEPROM
	BCF		STATUS,RP0		; Bank0
	MOVWF	EEADR			; 将地址赋予EEADR
	BSF		STATUS,RP0		; Bank1
	BSF		EECON1,RD		; EE Read
	BCF		STATUS,RP0		; Bank0
	MOVF	EEDATA,W		; W = EEDATA
	RETURN
WriteEEPROM
	BSF		STATUS,RP0 ; Bank1
	BCF		INTCON,GIE ; Disable INTs.
	BSF		EECON1,WREN ; Enable Write
	MOVLW	55h ;
	MOVWF	EECON2 ; 55h must be written to EECON2
	MOVLW	AAh ; to start write sequence
	MOVWF	EECON2 ; Write AAh
	BSF		EECON1,WR ; Set WR bit begin write
	BSF		INTCON,GIE ; Enable INTs.
	RETURN
	END
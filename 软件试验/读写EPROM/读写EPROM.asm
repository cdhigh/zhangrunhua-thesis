	LIST	P=16F716
	INCLUDE	P16F716.INC
Volume_Data	EQU	0x28
	ORG	0x00
;��ʼ��
;������
;----------------------------------------------------------
;�������ƣ�Read_EEPROM
;������������ȡEEPROM�ϴ�����ֵ����
;��������������ַ��w
;������������������w
;----------------------------------------------------------
Read_EEPROM
	BCF		STATUS,RP0		; Bank0
	MOVWF	EEADR			;����ַ����EEADR
	BSF		STATUS,RP0		; Bank1
	BSF		EECON1,RD		;��EEPROM
	BCF		STATUS,RP0		; Bank0
	MOVF	EEDATA,W		;�������w
	RETURN
Write_EEPROM
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
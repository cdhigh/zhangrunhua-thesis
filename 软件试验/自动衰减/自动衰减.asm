	LIST	P=16F818
	INCLUDE	P16F818.INC
Volume_Data		EQU
VOL_MAX		EQU
VOL_LIM		EQU
VOL_LIM_2	EQU
;----------------------------------------------------------
;�������ƣ�Auto_Vol
;���������
;���������
;�����������Զ�����������
;----------------------------------------------------------
Auto_Vol
	CALL	Read_Now_Vol		;��ȡ��ǰ������VOL_NOW
	MOVLW	0					;���������¼VOL_MAX��0
	MOVWF	VOL_MAX				;
	MOVLW	0xF0				;���ֵVOL_LIM��w
	MOVWF	VOL_LIM				;
	SUBWF	Volume_Data,1
	BTFSC	STATUS,Z
	GOTO	NOW_MORETHAN_LIMIT	;���
	BTFSS	STATUS,C
	GOTO	NOW_MORETHAN_LIMIT	;��ǰ�������ڼ���
	BTFSC	STATUS,C
	GOTO	NOW_LESSTHAN_LIMIT	;��ǰ����С�ڼ���
NOW_MORETHAN_LIMIT
	RRF		Volume_Data			;��������2(ѭ������һλ)
	BCF		Volume_Data,7		;��λ��0
	CALL	SET_VOL				;Ӧ������
	CALL	WAIT_500ms			;�ȴ�0.5s
	CALL	Read_Now_Vol		;��ȡ��ǰ������VOL_NOW
	MOVLW	VOL_LIM_2			;�����м�ֵVOL_LIM_2��w
	SUBWF	Volume_Data,1		;��ǰ�����뼫�ޱȽ�
	BTFSC	STATUS,Z
	GOTO	Auto_Vol			;��ǰ�����뼫�����
	BTFSS	STATUS,C
	GOTO	Auto_Vol			;��ǰ�������ڼ���
	CALL	WAIT_500ms			;�ȴ�0.5s
	MOVF	VOL_MAX				;/ʣ���������ǰ����С�ڼ���
	MOVWF	Volume_Data			;����������Ϊԭֵ
	RETURN
	END

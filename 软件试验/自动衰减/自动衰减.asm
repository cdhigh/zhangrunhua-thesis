	LIST	P=16F818
	INCLUDE	P16F818.INC
Volume_Data		EQU
VOL_MAX		EQU
VOL_LIM		EQU
VOL_LIM_2	EQU
;----------------------------------------------------------
;函数名称：Auto_Vol
;输入参数：
;输出参数：
;功能描述：自动调整音量。
;----------------------------------------------------------
Auto_Vol
	CALL	Read_Now_Vol		;读取当前音量到VOL_NOW
	MOVLW	0					;最大音量记录VOL_MAX置0
	MOVWF	VOL_MAX				;
	MOVLW	0xF0				;最大值VOL_LIM到w
	MOVWF	VOL_LIM				;
	SUBWF	Volume_Data,1
	BTFSC	STATUS,Z
	GOTO	NOW_MORETHAN_LIMIT	;相等
	BTFSS	STATUS,C
	GOTO	NOW_MORETHAN_LIMIT	;当前音量大于极限
	BTFSC	STATUS,C
	GOTO	NOW_LESSTHAN_LIMIT	;当前音量小于极限
NOW_MORETHAN_LIMIT
	RRF		Volume_Data			;音量除以2(循环右移一位)
	BCF		Volume_Data,7		;高位置0
	CALL	SET_VOL				;应用音量
	CALL	WAIT_500ms			;等待0.5s
	CALL	Read_Now_Vol		;读取当前音量到VOL_NOW
	MOVLW	VOL_LIM_2			;音量中间值VOL_LIM_2到w
	SUBWF	Volume_Data,1		;当前音量与极限比较
	BTFSC	STATUS,Z
	GOTO	Auto_Vol			;当前音量与极限相等
	BTFSS	STATUS,C
	GOTO	Auto_Vol			;当前音量大于极限
	CALL	WAIT_500ms			;等待0.5s
	MOVF	VOL_MAX				;/剩余情况，当前音量小于极限
	MOVWF	Volume_Data			;则音量设置为原值
	RETURN
	END

	LIST	P=16F818
	INCLUDE	P16F818.INC
;定义寄存器
Main_Status		EQU	0x10		;B7:电源状态;B6:喇叭继电器;B5:音量升降标志;B4:音量直调标志
Key_Record		EQU	0x1D		;按键结果数据
Key_AD_Count	EQU	0x1E		;按键扫描次数统计
Delay_3s_Cnt	EQU	0x1F		;3秒延时计数器
Delay_Cnt0	EQU	0x20			;延时计数器0
Delay_Cnt1	EQU	0x21			;延时计数器1
LED_OutCnt	EQU	0x22			;数码管输出段码计数
LED_HalfDat	EQU	0x23			;半字节待输出数据
LED_CS		EQU 0x24			;数码管片选
LED_DataH	EQU 0x25			;数码管显示数据高位
LED_DataL	EQU 0x26			;数码管显示数据低位
LED_Data	EQU 0x27			;待显示的数码管输入数据
Volume_Data	EQU 0x28			;M62649待输出音量值
Volume_Cnt	EQU 0x29			;M62649待输出位统计
;----------------------------------------------------------
;过程名称：Initial
;版本状态：完成
;功能描述：初始化IO
;----------------------------------------------------------
Initial_IO
	ORG	0
	BSF		STATUS,RP0
	MOVLW	B'00001111'			;x'x'x'电源电压‘功放中点’键盘’输出电压‘电流
	MOVWF	TRISA
	MOVLW	B'00000000'			;显示DATA'显示CLK'显示CS'显示CS'呼吸灯‘喇叭’电源‘空’
	MOVWF	TRISB
	BCF		STATUS,RP0
	CLRF	PORTA
	CLRF	PORTB
;----------------------------------------------------------
;*过程名称：Initial_AD
;版本状态：进行
;功能描述：初始化AD
;----------------------------------------------------------
Initial_AD
	BCF		STATUS,RP0			;体0
	MOVLW	B'01000001'			;D7 D6=01 AD转换时钟频率= FOSC/8
	MOVWF	ADCON0				;D5 D4 D3=000 AD转换模拟通道选择RA0/AN0
	BSF		STATUS,RP0			;体1
	MOVLW	B'00001110'			;D3 D2 D1 D0 1110选择RA0为模拟口。
	MOVWF	ADCON1				;D7=0左对齐 ADRESL的低六位读作0
	CLRF	ADRES
;----------------------------------------------------------
;过程名称：Delay_3s
;版本状态：完成
;功能描述：延时3秒启动系统，期间呼吸灯闪4次
;----------------------------------------------------------
Delay_3s
	BSF		OPTION_REG,0		;分频比256
	BSF		OPTION_REG,1		;分频比256
	BSF		OPTION_REG,2		;分频比256
	BCF		INTCON,T0IF			;将T0IF清0
	MOVLW	0xE5				;76,循环1s
	CLRF	TMR0				;重置TMR0
	MOVWF	Delay_3s_Cnt
Delay_3s_1	
	BTFSS	INTCON,T0IF	;Timer0溢出否?
	GOTO	Delay_3s_1			;否!返回上一步
	;呼吸灯开始
	BTFSC	Delay_3s_Cnt,6		;3秒内,呼吸灯闪4次
	BCF		PORTB,1
	BTFSS	Delay_3s_Cnt,6
	BSF		PORTB,1
	;呼吸灯结束
	DECFSZ	Delay_3s_Cnt,1		;减一次Delay_3s_Cnt,到0跳下句
	GOTO	Delay_3s_1			;继续Delay_3s_1
;----------------------------------------------------------
;过程名称：Set_Init_Vol
;版本状态：完成
;功能描述：读取EEPROM上次音量值数据，渐进调整音量
;----------------------------------------------------------
	MOVLW	0x20				;读入上次关机音量存储EEPROM地址
	CALL	Read_EEPROM			;输入地址到w，输出音量到w
	MOVWF	Volume_Cnt			;渐进音量次数
	MOVLW	0					;
	MOVWF	Volume_Data			;渐进音量初始值
Set_Init_Vol
	CALL	SET_Volume			;调用音量设置
	INCF	Volume_Data,1		;Volume_Data加一
	MOVF	Volume_Data,0		;Volume_Data赋予w
	XORWF	Volume_Cnt			;w中的Volume_Data与Volume_Cnt比较
	BTFSS	STATUS,Z			;测试结果是否0
	GOTO	Set_Init_Vol		;Volume_Data与Volume_Cnt不同继续循环
;----------------------------------------------------------
;过程名称：Loop_Main
;功能描述：主循环函数
;----------------------------------------------------------
Loop_Main
	

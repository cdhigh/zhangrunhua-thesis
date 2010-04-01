	LIST	P=16F818
	INCLUDE	P16F818.INC
;定义寄存器
Main_Status		EQU	0x10		;B7:电源状态;B6:喇叭继电器;B5:音量升降标志;B4:音量直调标志
Key_Record		EQU	0x1D		;按键结果数据
Key_AD_Count	EQU	0x1E		;按键扫描次数统计
Delay_3s_Cnt	EQU	0x1F		;3秒延时计数器
Delay_Cnt0		EQU	0x20		;延时计数器0
Delay_Cnt1		EQU	0x21		;延时计数器1
LED_OutCnt		EQU	0x22		;数码管输出段码计数
LED_HalfDat		EQU	0x23		;半字节待输出数据
LED_CS			EQU 0x24		;数码管片选
LED_DataH		EQU 0x25		;数码管显示数据高位
LED_DataL		EQU 0x26		;数码管显示数据低位
LED_Data		EQU 0x27		;待显示的数码管输入数据
Volume_Data		EQU 0x28		;M62649待输出音量值
Volume_Cnt		EQU 0x29		;M62649待输出位统计
;----------------------------------------------------------
;过程名称：START
;版本状态：完成
;功能描述：程序入口
;----------------------------------------------------------
START
	ORG		0x00
	NOP
	GOTO	MAIN				;转向主程序
	ORG 	0x04
	GOTO	INT_SERVER			;转向中断服务子程序
;----------------------------------------------------------
;*过程名称：Initial_IO_AD_INT
;版本状态：完成
;功能描述：初始化IO和AD和INT
;----------------------------------------------------------
Initial_IO_AD
;IO
	BSF		STATUS,RP0
	MOVLW	B'00001111'			;x'x'x'电源电压‘功放中点’键盘’输出电压‘电流
	MOVWF	TRISA
	MOVLW	B'00000000'			;显示DATA'显示CLK'显示CS'显示CS'呼吸灯‘喇叭’电源‘空’
	MOVWF	TRISB
	BCF		STATUS,RP0
	CLRF	PORTA
	CLRF	PORTB
;INT
	MOVLW	B'11001000'			;外设中断和RB中断使能
	MOVWF	INTCON
	MOVLW	B'01000000'			;AD中断使能
	MOVWF	PIE1
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
;过程名称：MAIN
;功能描述：主程序
;----------------------------------------------------------
MAIN
;自动调整音量
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
	CALL	SET_VOL				;应用音量
;----------------------------------------------------------
;函数名称：LED_Display
;输入参数：音量Volume_Data
;输出参数：
;功能描述：音量显示
;----------------------------------------------------------
LED_Display
;输入数字分离BCD码结果到w
	MOVLW	0x1E
	MOVWF	LED_Data				;输入LED_Data到W
	MOVF	LED_Data,0
	MOVWF	LED_HalfDat
	SWAPF	LED_Data,0
	ANDLW	0X0F
	CALL	BIN_HIGHHALF_BCD_TABLE
	MOVWF	LED_Data
	MOVF	LED_HalfDat,0
	ANDLW	0X0F
	CALL	BIN_LOWHALF_BCD_TABLE
	ADDWF	LED_Data,0
	MOVWF	LED_HalfDat
	ANDLW	0XF0
	MOVWF	LED_Data
	MOVF	LED_HalfDat,0
	ANDLW	0X0F
	CALL	BIN_LOWHALF_BCD_TABLE
	ADDWF	LED_Data,1				;转换结果到LED_Data
	MOVLW	0xF0					;将0F送LED_DataH，等AND做筛选
	MOVWF	LED_DataH
	MOVLW	0x0F					;将0F送LED_DataL，等AND做筛选
	MOVWF	LED_DataL
	MOVF	LED_Data,0
	ANDWF	LED_DataH,1
	SWAPF	LED_DataH,1
	ANDWF	LED_DataL,1				;将AND结果放w，准备查表转换
LOOP_LED	BTFSS	LED_CS,0		;根据LED_CS将LED_Data转到w
	MOVF	LED_DataH,0
	BTFSC	LED_CS,0
	MOVF	LED_DataL,0
	CALL	TABLE1					;按照w查表
	MOVWF	LED_HalfDat				;输出值
	BCF	PORTA,2						;片选脚PORTA,2输出0,选个位数码管
	MOVLW	0x08					;8次循环
	MOVWF	LED_OutCnt				;次数存LED_OutCnt
LOOP_BYTE
	BTFSS	LED_HalfDat,7			;测试LED_Data.7是否1,是则跳下句
	BCF	PORTA,1						;PORTA,1置0
	BTFSC	LED_HalfDat,7			;测试LED_Data.7是否0,是则跳下句
	BSF	PORTA,1						;PORTA,1置1
	RLF	LED_HalfDat,1				;左移一次LED_Data
	BSF	PORTA,0						;给一个时钟脉冲PORTA,0
	BCF	PORTA,0
	DECFSZ	LED_OutCnt,1			;减一次LED_OutCnt,到0跳下句
	GOTO	LOOP_BYTE				;继续LOOP_BYTE
	BCF	TRISA,2						;输出数字已准备好,设置TRISA,2输出
	BTFSC	LED_CS,0
	BSF	PORTA,2						;片选脚PORTA,2输出1,选十位数码管
	BTFSS	LED_CS,0
	BCF	PORTA,2						;片选脚PORTA,2输出0,选个位数码管
	CALL delay20ms					;延时200ms
	BSF	TRISA,2						;时间到，收回输出，设置片选高阻
	COMF	LED_CS,1				;如果LED_CS取反
	GOTO LOOP_LED
	SLEEP
;*****************段码表*****************
TABLE1	ADDWF	PCL,1
	RETLW	0X40;
	RETLW	0X79;
	RETLW	0X24;
	RETLW	0X30;
	RETLW	0X19;
	RETLW	0X12;
	RETLW	0X02;
	RETLW	0X58;
	RETLW	0X00;
	RETLW	0X10;
;***************用于将高半字节的BIN码换成整字节的压缩BCD码**********
BIN_HIGHHALF_BCD_TABLE
	ADDWF    PCL,1
	RETLW    B'00000000'     ;0
	RETLW    B'00010110'     ;16
	RETLW    B'00110010'     ;32
	RETLW    B'01001000'     ;48
	RETLW    B'01100100'     ;64
	RETLW    B'10000000'     ;80
	RETLW    B'10010110'     ;96
	RETLW    B'00101000'     ;128,失掉了百位
;***************用于将低半字节的BIN码换成整字节的压缩BCD码**********
BIN_LOWHALF_BCD_TABLE
	ADDWF    PCL,1
	RETLW    B'00000000'     ;0
	RETLW    B'00000001'     ;1
	RETLW    B'00000010'     ;2
	RETLW    B'00000011'     ;3
	RETLW    B'00000100'     ;4
	RETLW    B'00000101'     ;5
	RETLW    B'00000110'     ;6
	RETLW    B'00000111'     ;7
	RETLW    B'00001000'     ;8
	RETLW    B'00001001'     ;9
	RETLW    B'00010000'     ;A
	RETLW    B'00010001'     ;B
	RETLW    B'00010010'     ;C
	RETLW    B'00010011'     ;D
	RETLW    B'00010100'     ;E
	RETLW    B'00010101'     ;F
;*****************延时20ms子程序*****************
	GOTO	END_MAIN
	
delay20ms
	MOVLW	0x12
	MOVWF	Delay_Cnt0
delayLoopA	CLRF	Delay_Cnt1
delayLoopB	DECFSZ	Delay_Cnt1
	GOTO	delayLoopB
	DECFSZ	Delay_Cnt0
	GOTO	delayLoopA
	RETURN
	END_MAIN
	END

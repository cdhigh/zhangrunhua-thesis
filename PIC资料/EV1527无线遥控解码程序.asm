;有HOLTEK的程序改过来的， 如有指令笔误，麻烦自行修改啦。 ：）
;只贴主要程序， 其他部分请自己加心跳程序。
;*****************************************************************
;学习功能， 换一个新的遥控时，可以使用此功能确认该遥控为唯一的遥控，
;确认新遥控后，旧遥控无效
;*****************************************************************
;关键定义
; remote EV1527解调输入IO
; C 进位
; z ZERO标志
; ccl, cch 手工计数器
; leader, LEADER码， 就是EV1527有接收时发出的124CLK个低电平
; code_buf_1 ~ 3  记录当前接收到的24BIT
; code_dd_1 ~ 3 对应的遥控（唯一的出厂码，可以使用程序的学习功能来定义）
; buf_remote_1 ~ 3 学习时使用的缓存
; code_keep 当前键按住不放的标志
; xuexi_key  按键输入， 拉低有效
main:
			clrwdt
;记数加一
re_add:
			btfsc		remote		;io
			goto		turn_high
			clrwdt
			incf	ccl,1
			btfsc	C		;carry
			incf	cch.1
			goto	re_add
turn_high
			clr		int_ext			;计算一个波形结束，等待处理
no_ever_low:
;==============================================================
no_caling:
			btfsc	remote
			goto	main
			CLR		ccl
			CLR		cch
			goto	re_add
;重点部分， 解码
;确认是遥控中断，
int_ext:
;1、判断leader code
			btfsz	leader
			goto	incoding
config_leader:
		movlw	d'6'			;假设 4MHZ晶振的话
		subwf	cch,0
		btfss		C
		goto	code_error		;
		bsf		leader
		goto	exit_int
;*********************************************************
;*********************************************************
incoding:
;接收客户码和键盘码
		MOVlw	d'111'				;4MHZ是 111， 自己调节
		subwf	ccl,0
		RLC			code_buf3
		RLC			code_buf2
		RLC			code_buf1
		movlw	d'24'
		subwf		code_counter
		btfss		z			; z 0标志
		goto		exit_int
;*****************************************************************
;接收够24BIT
;*****************************************************************
;*****************************************************************
;学习功能， 换一个新的遥控时，可以使用此功能确认该遥控为唯一的遥控，
;确认新遥控后，旧遥控无效
;*****************************************************************
		;得到正确的遥控码，查表得键盘
		btfsc	xuexi_key		; 判断按键
		jmp		nn_key_keep	;不是在学习状态， 当作正常遥控码
;*********************************************************
		;判断当次学习是否完成
		btfsc		code_configed
		goto		exit_int
		movf	code_buf1,0
		xorwf	buf_remote_1,0
		btfss	z
		goto	error_keep			;前后码不相同
		movf	code_buf2,0
		xorwf	buf_remote_2,0
		btfss	z
		goto	error_keep			;前后码不相同
		movf	code_buf3,0
		xorwf	buf_remote_3,0
		btfss	z
		goto	error_keep			;前后码不相同
		;same code
		movf	buf_remote_time，0	;判断学习时间， 按键必须保持一段时间，防止误操作， 例如5秒
		btfss	z
		goto	nz_buf_remote_time
		;学习完成
		movf	buf_remote_1,0
		movwf	code_dd_1
		movf	buf_remote_2,0
		movwf	code_dd_2
		movlw	#0f0h
		andwf	buf_remote_3,0
		mvowf	code_dd_3
		CALL EEPROM_WRITE ;把遥控识别码存到EEPROM， 下次上电的时候读出
		                  ;EEPROM程序不在这个程序的讨论范围，不写了（懒）
		goto	exit_int		;结束
;*********************************************************
;*********************************************************
nz_buf_remote_time:
		decf		buf_remote_time,1
		goto		exit_int
error_keep:
		movf	code_buf1,0
		movwf	buf_remote_1
		movf	code_buf2,0
		movwf	buf_remote_2
		movf	code_buf3,0
		movwf	buf_remote_3
		mov		a,	100					;学习时间，按自己习惯来定义
		mov		buf_remote_time,	a
		goto	exit_int
;*********************************************************
;非学习时的解码
;*********************************************************
nn_key_keep:
		movf	code_dd_1,0
		xorwf	code_buf1,0
		btfss	z
		goto	code_error
		movf	code_dd_2,0
		xorwf	code_buf2,0
		btfss	z
		goto	code_error
		movlw	#0f0h
		andwf	code_dd_3,0
		xorwf	code_buf3,0
		btfss	z
		goto	code_error
		movf	remote_time,0			;遥控防抖动时间，因为1527是连续不断的发24BIT码,所以可以做个确认时间
		btfss	z
		goto	dec_remote_time
		btfsc	code_keep			;bit 操作
		goto	exit_int
		set		code_keep				;当前键按住不放的标志
;*************************************************************
		movlw	#0fh
		andwf	code_buf3,0
;*************************************************************
;确定一个有效的遥控按键
;*************************************************************
		;到此解码完成 W 中存放了当前的键值， 或者查表处理
		;请插入你相关的键处理指令
;*************************************************************
;*************************************************************
		goto	exit_int
;*************************************************************
dec_remote_time:
		dec		remote_time
		jmp		exit_int
;*************************************************************
;*************************************************************
code_error:
		bcf		leader
		CLR		code_buf_1
		CLR		code_buf_2
		CLR		code_buf_3
		CLR		code_counter
		bcf		code_configed		;无遥控信号是释放当前的学习正确标志
		mov		a,	dat_remote_time
		mov		remote_time,	a
;*************************************************************
exit_int:
		jmp		main
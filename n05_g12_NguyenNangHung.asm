#================================ Computer Architecture ============================
#	@Author: 	Nguyen Nang Hung
#	@StudentID:	20184118
#	@Student:	HEDSPI, SOICT, Hanoi University of Science and Technology
#	@Contact: 	Hung.nn184118@sis.hust.edu.vn
#	@Program: 	Postfix Converter and calculator
#	@Language: 	Assembly, MIPS, MARS-4.5
#===================================================================================
.data
Expression:	.space 100
Stack: 		.space 100
Postfix: 	.space 100

InputMessage:		.asciiz "Insert your expression in infix form (only allow 0 to 99): "
PostMessage: 		.asciiz "Your expression in postfix form: "
ValueMessage: 		.asciiz "Your expression value: "
ErrorParenthesis:  	.asciiz "You have made an parenthesis error!"
ErrorDivZero:		.asciiz "You have a division by zero error!"
CurrentValue:		.asciiz "Current value: "

AddMessage:			.asciiz "Detect '+' operator\n"
SubMessage:			.asciiz	"Detect '-' operator\n"
MulMessage:			.asciiz	"Detect '*' operator\n"
DivMessage:			.asciiz	"Detect '/' operator\n"
ModMessage:			.asciiz	"Detect '%' operator\n"
LParMessage:			.asciiz	"Detect '(' sign\n"
RParMessage:			.asciiz	"Detect ')' sign\n"
NumMessage:			.asciiz "Detect number\n"

StackPrintMessage: 	.asciiz " <=Current Stack\n"
PostPrintMessage: 	.asciiz " <=Current Postfix\n"

.text
	la $t9, Expression
	la $s0, Stack
	la $s1, Postfix

	# int stackSize = -1;
	li $s2, -1		# stackSize

	# int postSize = -1;
	li $s3, -1		# postSize

	# int c = 0;
	li $t0, -1		# value push to Stack

	# int lookAhead = 0;
	li $t1, -1 		# look ahead value

	# int token = 0;
	li $t2, 0		# value read from postfix expression

	# int tokenIndex = 0;
	li $t3, 0		# index of token

	# int popValue = 0;
	li $t4, 0		# numeric value of Stack

	# int i = 0; 
	li $t5, 0		# iterator

# ========================================= MAIN ====================================
postFixConverter:

	Read_keyboard:				# read entire expression
		li $v0, 54
		la $a0, InputMessage
		la $a1, Expression
		la $a2, 100
		syscall
		
		li $v0, 4
		la $a0, Expression
		syscall
		
		li $t5, 0				# set  i = 0;
	get_character:
		beq $t0, 0, done_keyReading #if c == 0 then stop loop
		nop
		
		bne $t1, -1, elsest		# if lookAhead == -1, then init c
			add $k0, $t9, $t5	# k0 = &Expression[0] + i = &Expression[i]
			lb  $t0, 0($k0)		# c <= Expression[i]
			j cont_main
			nop
		elsest:					# if lookAhead != -1 then c <= lookAhead
			add $t0, $t1, $0		# c <= lookAhead
			j cont_main
			nop
		cont_main:
			addi $t6, $t5, 1		# t6 = i + 1
			add $k0, $t9, $t6	# k0 = &Expression[0] + i + 1 = &Expression[i + 1]
			lb  $t1, 0($k0)		# lookAhead <= Expression[i + 1]

			#============================= SWITCH CASE c ============================
			start:
				bne $t0, '+', readsub
				nop
				# print stack
				li $v0, 4
				la $a0, Stack
				syscall
				la $a0, StackPrintMessage
				syscall
				la $a0, AddMessage
				syscall
				# compile
				jal readAddSub
				nop
				j end_switch
				nop
			readsub:
				bne $t0, '-', readmul
				nop
				# print stack
				li $v0, 4
				la $a0, Stack
				syscall
				la $a0, StackPrintMessage
				syscall
				la $a0, SubMessage
				syscall
				# compile
				jal readAddSub
				nop
				j end_switch
				nop
			readmul:
				bne $t0, '*', readdiv
				nop
				# print stack
				li $v0, 4
				la $a0, Stack
				syscall
				la $a0, StackPrintMessage
				syscall
				la $a0, MulMessage
				syscall
				# compile
				jal readMulDiv
				nop
				j end_switch
				nop
			readdiv:
				bne $t0, '/', readmod
				nop
				# print stack
				li $v0, 4
				la $a0, Stack
				syscall
				la $a0, StackPrintMessage
				syscall
				la $a0, DivMessage
				syscall
				# compile
				jal readMulDiv
				nop
				j end_switch
				nop
			readmod:
				bne $t0, '%', readlpar
				nop
				# print stack
				li $v0, 4
				la $a0, Stack
				syscall
				la $a0, StackPrintMessage
				syscall
				la $a0, ModMessage
				syscall
				# compile
				jal readModule
				nop
				j end_switch
				nop
			readlpar:
				bne $t0, '(', readrpar
				nop
				# print stack
				li $v0, 4
				la $a0, Stack
				syscall
				la $a0, StackPrintMessage
				syscall
				la $a0, LParMessage
				syscall
				# compile
				jal readLeftPar
				nop
				j end_switch
				nop
			readrpar:
				bne $t0, ')', readspace
				nop
				# print stack
				li $v0, 4
				la $a0, Stack
				syscall
				la $a0, StackPrintMessage
				syscall
				la $a0, RParMessage
				syscall
				# compile
				jal readRightPar
				nop
			readspace:
				bne $t0, ' ', end_switch
				nop
				j loop_again
				nop
			#================================ END SWITCH ============================
	end_switch:
		slti $s4, $t0, '0'		# $s4 = 1 if c < '0'
		sgt $s5, $t0, '9'		# $s5 = 1 if c > '9'
		or 	 $s6, $s4, $s5		# $s6 = 1 if c < '0' or c > '9' => not number, then loop again 
		beq  $s6, 1, loop_again # => if not number, loop again
		nop
		# print message
		li $v0, 4
		la $a0, NumMessage
		syscall
		# compile
		jal pushPost		# if number, push to Postfix
		nop

		sgt $s4, $t1, 47 		# $s4 = 1 if '0' < lookAhead 
		slti $s5, $t1, 58		# $s4 = 1 if  lookAhead < '9'
		and $s6, $s4, $s5		# $s6 = 1 if '0' < lookAhead < '9' => number
		beq $s6, 1, loop_again	# if number, loop again
		nop
		jal pushSpace			# if not number, push a space into Postfix
		nop
		
		li $v0, 4
		la $a0, Postfix
		syscall
		la $a0, PostPrintMessage
		syscall
		
		loop_again:
		addi $t5, $t5, 1	# increase i += 1
		j get_character		# loop back
		nop

	done_keyReading:
		jal endReading
		nop
		jal printPost
		nop
		jal computePostFix
		nop
		lb $a3, 0($s0)		
		li $v0, 56
		la $a0, ValueMessage
		add $a1, $a3, $0
		syscall

end: 
	li $v0, 10
	syscall
# ==================================== END MAIN =====================================
error_parenthesis:
	li $v0, 55
	la $a0, ErrorParenthesis
	syscall
	j end

Error_DivByZero:
	li $v0, 55
	la $a0, ErrorDivZero
	syscall
	j end
#============================ Functions used in this work =============================
#id	|Name				|	Using for												|
#--------------------------------------------------------------------------------------
#1	|pushPost			|	Push a value into Postfix								|
#2	|popPost				|	Move the top value of Postfix to Stack					|
#3	|pushSpace			|	Push a ' ' character into Postfix						|
#4	|pushStack			|	Push the read character into Stack						|
#5	|popStack			|	Remove the top value of Stack							|
#6	|readAddSub			|	Read '+' and '-' operator								|
#7	|readMulDiv			|	Read '*' and '/' operator								|
#8	|readModule			|	Read '%' operator										|
#9	|readLeftPar			|	Read '(' sign											|
#10	|readRightPar		|	Read ')' sign											|
#11	|endReading			|	Complete reading process, pop all value in Stack			|
#12	|printPost			|	Print Postfix to screen									|
#13	|postFixConverter	|	Main function											|
#14	|getTokenValue		|	Get true value or operator code from Postfix				|
#15	|computePostFix		|	Calculate postfix value									|
#======================================================================================

pushPost:				# pushPost ()
	addi $s3, $s3, 1		# postSize ++;
	add $k0, $s3, $s1	# &Postfix[0] + postSize = &Postfix[postSize]
	sb	$t0, 0($k0)		# Postfix[postSize] = c;
	jr  $ra				# end function


popPost:					# popPost()
	slt $t6, $0, $s3		# if (postSize < 0) return;
	beq $t6, 1, endpopPost
	nop
	add $k1, $s3, $s1	# $k1 = &Postfix[0] + postSize = &Postfix[postSize]
	lb 	$t6, 0($k1)		# $t6 <= Postfix[postSize]
	addi $s2, $s2, 1		# stackSize ++;
	add $k0, $s2, $s0	# $k0 = &Stack[0] + stackSize = &Stack[stackSize]
	sb  $t6, 0($k0)		# &Stack[stackSize] <= Postfix[postSize]
	addi $s3, $s3, -1	# postSize --;
	endpopPost:
		jr $ra			# end function


pushSpace:				# pushSpace()
	addi $s3, $s3, 1		# postSize ++;
	add $k0, $s3, $s1	# $k0 = &Postfix[0] + postSize = &Postfix[postSize]
	li  $t6, ' '
	sb  $t6, 0($k0)		# Postfix[postSize] <= ' ';
	jr $ra				# end function


pushStack:				# pushStack()
	addi $s2, $s2, 1		# stackSize ++;
	add $k0, $s2, $s0	# $k0 = &Stack[0] + stackSize = &Stack[stackSize]
	sb	$t0, 0($k0)		# Postfix[postSize] <= c;
	jr  $ra				# end function


popStack:							# popStack()
	add $a0, $ra, $0					# create path back
	beq $s2, -1, endpopStack			# if (stackSize < 0) return;
	nop
	add $k0, $s2, $s0				# $k0 = &Stack[0] + stackSize = &Stack[stackSize]
	lb  $t6, 0($k0)					# $t6 <= Stack[stackSize]
	beq $t6, '(', cont_popStack		# if Stack[stackSize] == '(' then continue
	nop
	beq $t6, ')', cont_popStack		# if Stack[stackSize] == ')' then continue
	nop

	add $t4, $t6, $0					# popValue = Stack[stackSize]

	addi $s3, $s3, 1					# postSize ++;
	add $k1, $s3, $s1				# $k1 = &Postfix[0] + postSize = &Postfix[postSize]
	sb 	$t4, 0($k1)					# $t4 = popValue => Postfix[postSize]

	# pushSpace ()
	jal pushSpace
	nop

	cont_popStack:
		addi $s2, $s2, -1	# stackSize --;
	endpopStack:
		jr $a0
	

readAddSub:				# readAddSub()
	add $a1, $ra, $0
	loopAddSub:
		beq $s2, -1, cont_readAddSub	# if stackSize == -1, continue
		nop
		add $k0, $s2, $s0	# $k0 = stackSize + &Stack[0] = &Stack[stackSize]
		lb  $t6, 0($k0)		# $t6 <= Stack[stackSize]
		
		beq $t6, '+', popAddSub	# if Stack[stackSize] == '+', pop
		beq $t6, '-', popAddSub	# if Stack[stackSize] == '-', pop
		beq $t6, '*', popAddSub	# if Stack[stackSize] == '*', pop
		beq $t6, '/', popAddSub	# if Stack[stackSize] == '/', pop
		beq $t6, '%', popAddSub	# if Stack[stackSize] == '%', pop
		nop
		j cont_readAddSub
		nop	
		
		popAddSub:
			jal popStack			# pop all out or until meet '('
			nop
			j loopAddSub			# go loop
			nop

	cont_readAddSub:
		jal pushStack	# add new read character into Stack
		nop

	jr $a1				# end function


readMulDiv:				# readMulDiv()
	add $a1, $ra, $0
	loopMulDiv:
		beq $s2, -1, cont_readMulDiv	# if stackSize == -1, continue
		nop
		add $k0, $s2, $s0	# $k0 = &Stack[0] + stackSize = &Stack[stackSize]
		lb  $t6, 0($k0)		# $t6 <= Stack[stackSize]
		beq $t6, '*', popMulDiv	# if Stack[stackSize] == '*' then pop
		nop
		beq $t6, '/', popMulDiv	# if Stack[stackSize] == '/' then pop
		nop
		beq $t6, '%', popMulDiv	# if Stack[stackSize] == '%' then pop
		nop
		j cont_readMulDiv		# if not, then push new character into Stack
		
		popMulDiv:
			jal popStack
			nop
		j loopMulDiv
		
	cont_readMulDiv:
		jal pushStack		# add new read character into Stack
		nop

	jr $a1					# end function
	

readModule:					# readModule()
	add $a1, $ra, $0
	loopModule:
		beq $s2, -1, cont_readModule	# if stackSize == -1, continue
		nop
		add $k0, $s2, $s0	# $k0 = &Stack[0] + stackSize = &Stack[stackSize]
		lb  $t6, 0($k0)		# $t6 <= Stack[stackSize]
		bne $t6, '%', cont_readModule
		nop
		jal popStack
		nop
		j loopModule

	cont_readModule:
		jal pushStack		# add new read character into Stack
		nop

	jr $a1					# end function


readLeftPar:				# readLeftPar()
	add $a1, $ra, $0
	jal pushStack
	nop
	jr $a1


readRightPar:				# readRightPar()
	add $a1, $ra, $0
	loopRightPar:
		add $k0, $s2, $s0	# $k0 = &Stack[0] + stackSize = &Stack[stackSize]
		lb  $t6, 0($k0)		# $t6 <= Stack[stackSize]

		beq $t6, '+', popRPar
		nop
		beq $t6, '-', popRPar
		nop
		beq $t6, '*', popRPar
		nop
		beq $t6, '/', popRPar
		nop
		beq $t6, '%', popRPar
		nop
		beq $t6, ')', popRPar
		nop
		beq $t6, '(', cont_readRightPar	# if found left par, stop
		nop
		beq $s2, -1, error_parenthesis	# print parenthesis error
		nop
		
		popRPar:
			jal popStack
			nop
			j loopRightPar
			nop 

	cont_readRightPar:					# pop out left par
		jal popStack
		nop
	jr $a1


endReading:					# endReading()
	add $a1, $ra, $0
	loopReading:
		beq $s2, -1, cont_endReading	# if stackSize == -1 then stop
		nop
		
		add $k0, $s2, $s0		# $k0 = &Stack[0] + stackSize = &Stack[stackSize]
		lb  $t6, 0($k0)			# $t6 <= Stack[stackSize]
		beq $t6, 40, error_parenthesis
		nop
		
		jal popStack					# else, keep popStack
		nop
		j loopReading
		nop
	
	cont_endReading:
		jr $a1


printPost:					# printPost()
	li $v0, 59
	la $a0, PostMessage
	la $a1, Postfix
	syscall
	jr $ra


getTokenValue:			# getTokenValue()
	add $k1, $t3, $s1	# $k1 = &Postfix[0] + tokenIndex = &Postfix[tokenIndex]
	lb 	$t6, 0($k1)		# $t6 <= Postfix[tokenIndex]

	add $t2, $t6, $0		# token = 0 + Postfix[tokenIndex] = Postfix[tokenIndex]

	addi $t3, $t3, 1		# tokenIndex ++
	add $k1, $t3, $s1	# $k1 = &Postfix[0] + (tokenIndex + 1) = &Postfix[tokenIndex + 1]
	lb  $t1, 0($k1)		# lookAhead = Postfix[tokenIndex + 1]

	slti $s4, $t2, '0'	# $s4 = 1 if token < '0'
	sgtu $s5, $t2, '9'	# $s5 = 1 if token > '9'

	or $s6, $s4, $s5		# $s6 = 1 if $s4 true or $s5 true
	beq $s6, 1, step_2_TokenValue
	nop
	addi $t2, $t2, -48		# if '0' < token < '9' then convert token to true value
	step_2_TokenValue:
		bne $t1, ' ', step_3_TokenValue
		addi $t3, $t3, 1		# if lookAhead == ' ' then tokenIndex ++
		j endTokenValue		# instantly return

	step_3_TokenValue:
		sgt $s4, $t1, 47 		# $s4 = 1 if '0' < lookAhead 
		slti $s5, $t1, 58		# $s4 = 1 if  lookAhead < '9'
		and $s6, $s4, $s5		# $s6 = 1 if '0' < lookAhead < '9' => number
		bne $s6, 1, endTokenValue	# if not number, loop again
		nop
		
		#slti $s4, $t1, 47	# $s4 = 1 if lookAhead < '0'
		#sgtu $s5, $t1, 58	# $s5 = 1 if lookAhead > '9'
		#or $s6, $s4, $s5		# $s6 = 1 if $s4 true or $s5 true
		#beq $s6, 1, endTokenValue
		#nop
		
		addi $t1, $t1, -48	# if '0' <= lookAhead <= '9' then convert lookAhead to true value
		mul $t2, $t2, 10		# token = 10 * token
		add $t2, $t2, $t1	# token = token + lookAhead
		addi $t3, $t3, 2		# tokenIndex += 2

	endTokenValue:
		jr $ra


computePostFix:				#computePostFix()
	add $a2, $ra, $0
	or  $a0, $a3, 0x1
	srl $a3, $s3, 1			# a3 = postSize/2 
	beq $a0, 0, not_odd
	addi $a3, $a3, 1			# if a3 % 2 == 1 then a3 += 1 
	not_odd:
	li $t5, 0				# i = 0
	
	loopCompute:
		slt $t6, $a3, $t5	# t6 = 1 if a3 < t5 <=> (postSize/2) < i
		beq $t6, 1, endCompute
		nop
		addi $t5, $t5, 1		# i = i + 1
		
		jal getTokenValue
		#beq $t2, 0, endCompute	# if token == 0, end compute
		#nop
				bne $t2, '*', divop
				nop
				#======================== Begin '*' ============================
				jal popStack
				nop
				add $t7, $t4, $0		# t7 = popValue
				jal popStack
				nop
				mul $t0, $t7, $t4		# c = t7 * popValue, store back to Stack
				jal pushStack
				nop
				#li $v0, 56
				#la $a0, CurrentValue
				#add $a1, $t0, $0
				#syscall
				j loopCompute
				nop		
				#======================== Finish '*' ===========================
		divop: 	bne $t2, '/', modop
				nop
				#======================== Begin '/' ============================
				jal popStack
				nop
				add $t7, $t4, $0			# t7 = popValue
				beq $t7, $0, Error_DivByZero
				nop
				jal popStack
				nop
				div		$t4, $t7			# $t4 / $t7
				mflo		$t0				# c = $t0 = floor($t4 / $t7) 
				jal pushStack			# store c back to Stack
				nop
				#li $v0, 56
				#la $a0, CurrentValue
				#add $a1, $t0, $0
				#syscall
				j loopCompute
				#======================== Finish '/' ===========================
		modop: 	bne $t2, '%', addop
				nop
				#======================== Begin '%' ============================
				jal popStack
				nop
				add $t7, $t4, $0			# t7 = popValue
				beq $t7, $0, Error_DivByZero
				nop
				jal popStack
				nop
				div		$t4, $t7			# $t4 / $t7
				mfhi		$t0				# c = $t0 = $t4 mod $t7 
				jal pushStack			# store c back to Stack
				nop
				#li $v0, 56
				#la $a0, CurrentValue
				#add $a1, $t0, $0
				#syscall
				j loopCompute
				#======================== Finish '%' ===========================
		addop: 	bne $t2, '+', subop
				nop
				#======================== Begin '+' ============================
				jal popStack
				nop
				add $t7, $t4, $0		# t7 = popValue
				jal popStack
				nop
				add $t0, $t4, $t7		# c = t4 + t7
				jal pushStack			# store c back to Stack
				nop
				#li $v0, 56
				#la $a0, CurrentValue
				#add $a1, $t0, $0
				#syscall
				j loopCompute
				#======================== Finish '+' ===========================
		subop: 	bne $t2, '-', char
				nop
				#======================== Begin '%' ============================
				jal popStack
				nop
				add $t7, $t4, $0		# t7 = popValue
				jal popStack
				nop
				sub	$t0, $t4, $t7		# c = $t4 - $t7
				jal pushStack			# store c back to Stack
				nop
				#li $v0, 56
				#la $a0, CurrentValue
				#add $a1, $t0, $0
				#syscall
				j loopCompute
				#======================== Finish '%' ===========================
		char:	# if read a number, add it to the stack
			add $t0, $t2, $0
			jal pushStack
			nop
			
			j loopCompute
			nop

	endCompute:
	jr $a2

#============================================= END FILE =========================================

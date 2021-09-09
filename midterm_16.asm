.data 	
	String_message:	.asciiz	"Input string is: "
	Notice_message:	.asciiz	"Number of different characters is: "
	Message:		.space	100	# Buffer 100 byte
.text 
main:	
	li	$v0, 8
	la	$a0, Message
	li	$a1, 100
	syscall
	addi 	$sp, $sp, -100		# Load appear_character to $sp 
	la	$s0, Message		# Load Message to $s0
	add	$t0, $0, $0		# init $t0 = i = 0
	add	$t1, $0, $0		# init $t1 = count = 0
	add	$t2, $0, $0		# init $t2 = j = 0
	
	jal	check
	nop
print:	li	$v0, 59
	la	$a0, String_message
	la	$a1, Message
	syscall
	add	$a1, $t1, $0
	li	$v0, 56	
	la	$a0, Notice_message
	syscall
quit:	li	$v0, 10
	syscall

#-------------------------------------------------------------------------------------
# @brief		Check character in input string Message, reomove space_character

#-------------------------------------------------------------------------------------

check:	add	$t3, $s0, $t0		# $t3 = Address of Message[i]
	lb	$t4, 0($t3)		# Load word $t4 = Message[i]	
	beq	$t4, 10, check_done		# If $t4 = 10 ==> check done
	nop
	beq	$t0, 24, check_done		# If appear_char = 24, 'a' - 'z' appeared ==> check done
	nop
	add	$t2, $0, $0		# init $t2 = j = 0
	addi	$t0, $t0, 1		# i = i+1
	add	$t5, $0, $sp
check_appear:
	slti	$t6, $t4, 'a'		# If message[i] < 'a' ==> check next character
	bne	$t6, $0, check
	slti	$t6, $t4, 128		# If Message[i] > 128 ('z') ==> check next character
	beq	$t6, $0, check
	slt	$t7, $t1, $t2		# if j > count, add current character to appear_character
	bne	$t7, $0, add_char 	
	nop
	lw	$t7, 0($t5)		# load value of appear_character[j]
	beq	$t7, $t4, check		# if Massage[i] = appear_character[j]
	nop
	addi	$t2, $t2, 1		# j = j+1
	addi	$t5, $t5, 4		
	j	check_appear
	nop
add_char:	sw	$t4, 0($t5)		# Message[i] is new character
					# add to appear_character[count]
	addi	$t1, $t1, 1		# count = count+1 
	j	check
	nop
check_done:	
	jr	$ra

.data
MessageInput: .asciiz "Enter a string (less than 100 characters, end with enter): \n"
Buffer:	.space	100
YesMessage: .asciiz "Yes, parenthesis: "
NoMessage: .asciiz "No, not parenthesis: "

.text
	li $s0, 0	#init i = 0, length of the string
	la $k0, Buffer	# $k0 = &Buffer[0], let $k1 be &Buffer[i]

Read_keyboard:
	li $v0, 4
	la $a0, MessageInput
	syscall
get_character:
	beq $s0, 99, Check_parenthesis #if string length is 99, check parenthesis
	nop
	li $v0, 12	#read characters letter by letter
	syscall
	beq $v0, 10, Check_parenthesis #if input '\n' then check parenthesis
	add $k1, $k0, $s0	# k1 = &Buffer[0] + i = &Buffer[i]
	sb $v0, 0($k1)		# store read character into &Buffer[i]
	addi $s0, $s0, 1	# increase i += 1
	j get_character
	nop
Check_parenthesis:
	add $s1, $s0, $0 # store length of string into $s1
	srl $s2, $s1, 1 # s2 = s1 / 2 => threshold to loop i
	li $s0, 0	# reset i = 0
	# Current situation: i = num_character, 
	# last character address: $k1, 
	# first character address: $k0,
	# Loop i++: check if *(&A[0] + i) == *($k1 - i), if not, conclude no
Loop:
	slt $s3, $s2, $s0	# s3 = threshold < i ? 1 : 0
	bne $s3, $0, Conclude_yes 
	nop
	# s3 = 1 then i has gone to middle of the string 
	# => All is checked, conclude yes
	add $t1, $s0, $k0	# t1 = i + &A[0] = &A[i]
	lb  $t2, 0($t1)		# t2 = A[i]
	
	sub $t3, $0, $s0	# t3 = 0 - i = -i
	
	add $t4, $t3, $k1	# t4 = -i + &A[last] = &A[last -i]
	lb $t5, 0($t4)		# t5 = A[last - i]
	
	bne $t2, $t5, Conclude_no	#if A[i] != A[last - i] then conclude no
	addi $s0, $s0, 1	# i += 1
	j Loop
	nop
	
Conclude_yes:
	li $v0, 59
	la $a0, YesMessage
	la $a1, Buffer
	syscall
	j end
	
Conclude_no:
	li $v0, 59
	la $a0, NoMessage
	la $a1, Buffer
	syscall
	j end

end: 
	li $v0, 10
	syscall

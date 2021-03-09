.data
line:
	.asciiz	"\n"
msg_not_found:
	.asciiz "\nFail!\n"
msg_found:
	.asciiz "\nSuccess! Location: "
str:
	.space	100000			# max string length
map:
	.word	256

.text
init:
	la	$s0, map		# s0 = map
	li	$t0, 255		# t0 = len(map) - 1
	sll	$t0, $t0, 2		# 4 bytes per word
	add	$t0, $s0, $t0		# t0 = map[len(map) - 1]
reset_map:
	sub	$t1, $t0, $s0		# t1 = t0 - s0
	blt	$t1, $zero, main	# if (t1 < 0)
	sw	$zero, ($t0)		# *t0 = 0
	sub	$t0, $t0, 4
	j	reset_map
	
main:
	li	$v0, 8			# input string
	la	$a0, str		# set string addr.
	li	$a1, 100000		# set string max length
	syscall				# implement
	
	la	$s1, str		# start addr. of string
	la	$s2, str		# end addr of string [s1, s2]
find_end:
	lb	$t0, ($s2)		# t0 = *s2
	beq	$t0, $zero, done_find	# done counting
	addi	$s2, $s2, 1		# string addr. + 1
	j	find_end
	
done_find:
	sub	$s3, $s2, $s1		# s3 = len(string)
	subi	$s2, $s2, 1		# set s2 to the last char of the string, which should be '\n'
gen_map:
	sub	$t0, $s2, $s1		# t0 = s2 - s1
	blt	$t0, $zero, listen	# if (t0 < 0)
	lb	$t1, ($s2)		# t1 = *s2
	sll	$t1, $t1, 2		# 4 bytes per word
	add	$t1, $s0, $t1		# t1 = &map[char]
	sw	$s3, ($t1)		# map[char] = pos
	
	subi	$s2, $s2, 1		# addr. of char --
	subi	$s3, $s3, 1		# char pos count --
	j	gen_map
	
listen:
	li	$v0, 12			# read char
	syscall
	beq	$v0, '?', exit		# if (v0 == '?') exit
	
	sll	$t0, $v0, 2		# t0 = pos
	add	$t0, $s0, $t0		# t0 = map[pos]
	lw	$t1, ($t0)		# t1 = *p0
	beq	$t1, $zero, not_found	# if(t1 == 0) not_found
	
	# must be found now
	li	$v0, 4			# ready for output a string
	la	$a0, msg_found
	syscall
	li	$v0, 1			# ready for output an integer
	move	$a0, $t1
	syscall
	li	$v0, 4			# ready for output a string
	la	$a0, line
	syscall
	j	listen

not_found:
	li	$v0, 4			# ready for output a string
	la	$a0, msg_not_found
	syscall
	j	listen
			
exit:
	li	$v0, 4			# ready for output a string
	la	$a0, line
	syscall
	

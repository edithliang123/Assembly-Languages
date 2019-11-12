##########################################################################
# Created by:  Liang, Yixin
#              yliang43
#              24 May 2019
#
# Assignment:  Lab 4: Roman Numeral Conversion
#              CMPE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Spring 2019
# 
# Description: This program reads roman numerals from program argument, check if it is valid and convert it to binary representation
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################

# In the main function {
#	print the program argument
#	check if the argument contains non roman numerals numbers, if so, call error
#	check if the argument is in descending order by compare each roman numeral value with previous value
#	add up each roman numeral value. If not, call error
#	Take the largest roman numeral in argument and compare it with the sum of the rest roman numerals
#	if it exceed the largest roman numeral, call error
#	if the argument pass both checks, call convert
#	}
#
#function error(){
#	print error message
#	}
#
#function convert(){
#	convert the value to binary 
#   	print the register that stores the binary representation in correct order
#	}

.data
	respond: .asciiz "You entered the Roman numerals:"
	newline: .asciiz "\n"
	null: .asciiz ""
	input: .space 20
	roman: .asciiz "IVXLCD"
	pair1: .asciiz "VX"
	pair2: .asciiz "LC"
	pair3: .asciiz "DM"
	message: .asciiz "Error: Invalid program argument.\n"
	printmessage:.asciiz "The binary representation is:\n"
	printbinary:.asciiz "0b"
.text
# REGISTER USAGE
# $v0: syscall
# $a0: syscall
# $s0: store argument and byte load
# $s2: store null byte
	li $v0, 4
	la $a0, respond
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	lw $s0, ($a1)		#load program argument to $s0
	li $v0, 4
	la $a0, ($s0)		#print program argument that stored in $s0
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	lb $t0, ($s0)			#$s0 stores value of bytes that point to in argument
	lb $s2, null			#set $s2 to a null byte
	j check2
# REGISTER USAGE
# $t1: store boolean outcome
# $t2: store boolean outcome
# $s0: byte count
# $s1: byte count
# $s2: store null byte
	check: 
	beq $t2, 0, error		#$t2 used to determine if each roman numeral of argument is valid
	addi $s0, $s0, 1		#$s0 stores value of bytes that point to in argument
	lb $t0, ($s0)			
	beq $t0, $s2, clean		#compare with $s2 to determine if argument reaches the end
	move $s1, $0			#reset $s1 to 0 for next roman numeral check
	j check2
		check2: 
		lb $t1, roman($s1)	#load bytes of roman to $t1, $s1 used to increment byte	

		addi $s1, $s1, 1	#increment $s1 by 1
		beq $t1, $s2, check	#compare with $s2 to determine if argument reaches the end
		
		seq $t2, $t1, $t0
		beq $t2, 1, check
		beq $t2, 0, check2
	
	clean:				#reset register for next check process
	lw $s0, ($a1)
	j determine
# REGISTER USAGE
# $t0: load byte
# $t1: load btye
# $t2: store boolean outcome
# $s0: byte count
	determine: 			#start check descending order
	move $t2, $0
	move $s1, $0
	lb $t0, ($s0)			#$t0 stores the first byte of the argument
	lb $t1, roman			#$t1 stores the first byte of the roman string
	beq $t0, $t1, order1		#if $t0 matches with one roman numeral in roman string then jump to certain order
	lb $t1, roman+1		
	beq $t0, $t1, order2
	lb $t1, roman+2
	beq $t0, $t1, order3
	lb $t1, roman+3
	beq $t0, $t1, order4
	lb $t1, roman+4
	beq $t0, $t1, order5
	lb $t1, roman+5
	beq $t0, $t1, order6
# REGISTER USAGE
# $s0: byte count
# $s1: count roman numeral appear times
# $s2: store null byte	
# $s3: store value of roman numeral
# $s4: boolean outcome
# $s7: store sum of roman numeral value
# $t2: count roman numeral appear times
# $t3: store loaded byte
# $t6: count roman numeral appear times
# $t7: count roman numeral appear times
# $t8: count roman numeral appear times
# $t9: count roman numeral appear times
	order1: 
	addi $s3, $0, 1			#set the $s3 to the matched roman numeral value
	addi $t2, $t2, 1			#increment $t2 if I appeared once
	move $s7, $s3				#$s7 record the value of roman numeral and add up to calculate the total value as program proceed
	j checkpair1
		checkpair1: 			#checkpair checks if the next byte can be paired with current byte
		lb $t3, pair1			#$t3 stores the first byte of pair1
		addi $s0, $s0, 1	
		lb $s4, ($s0)			#$s4 stores the next byte of current byte ($t0)
		beq $s4, $t3, subtract1	
		lb $t3, pair1+1
		beq $s4, $t3, subtract2
		bne $s4, $t3, compare
			subtract1:
			addi $s3, $0, 4	#set the $s3 to the matched roman numeral value after bytes paired
			move $s7, $s3
			addi $s0, $s0, 1 
			j compare
			subtract2:
			addi $s3, $0, 9	#set the $s3 to the matched roman numeral value after bytes paired
			move $s7, $s3
			addi $t7, $t7, 10	#increment $t7 by 10 if it has been paired for the last check
			addi $s0, $s0, 1
			j compare
		
	order2:
	addi $s3, $0, 5			#set the $s3 to the matched roman numeral value
	move $s7, $s3
	addi $t6, $t6, 1			#increment $t6 if V appeared once
	addi $s0, $s0, 1			#increment $s0 for next register to store byte
	j compare
	
	order3:
	addi $s3, $0, 10			#set the $s3 to the matched roman numeral value
	addi $t7, $t7, 1			#increment $t7 if X appeared once
	move $s7, $s3
	j checkpair2
		checkpair2:
		lb $t3, pair2			
		addi $s0, $s0, 1
		lb $s4, ($s0)
		beq $s4, $t3, subtract3
		lb $t3, pair2+1
		beq $s4, $t3, subtract4
		bne $s4, $t3, compare
			subtract3:
			addi $s3, $0, 40	#set the $s3 to 40 since the roman numeral is XL at this point
			move $s7, $s3
			addi $s1, $s1, 50	#increment $s1 by 50 if it has been paired for the last check
			addi $s0, $s0, 1 
			j compare
			subtract4:
			addi $s3, $0, 90	#set the $s3 to 90 since the roman numeral is XC at this point
			move $s7, $s3
			addi $t8, $t8, 100	#increment $t8 by 100 if it has been paired for the last check
			addi $s0, $s0, 1
			j compare
	order4:
	addi $s3, $0, 50			#set the $s3 to the matched roman numeral value
	move $s7, $s3				
	move $s1, $0
	addi $s1, $s1, 1			#increment $s1 if L appeared once
	addi $s0, $s0, 1
	j compare
	
	order5:
	addi $s3, $0, 100
	addi $t8, $t8, 1			#increment $t8 if C appeared once
	move $s7, $s3
	j checkpair3
		checkpair3:
		lb $t3, pair3
		addi $s0, $s0, 1
		lb $s4, ($s0)
		beq $s4, $t3, subtract5
		lb $t3, pair3+1
		beq $s4, $t3, subtract6
		bne $s4, $t3, compare
			subtract5:
			addi $s3, $0, 400		#set the $s3 to 400 since the roman numeral is CD at this point
			move $s7, $s3
			addi $t9, $t9, 500		#increment $t9 by 500 if it has been paired for the last check
			addi $s0, $s0, 1 
			j compare
			subtract6:
			addi $s3, $0, 900		#set the $s3 to 900 since the roman numeral is CM at this point
			move $s7, $s3
			addi $s0, $s0, 1
			j compare		
	order6:
	addi $s3, $0, 500			#set the $s3 to the matched roman numeral value
	move $s7, $s3
	addi $t9, $t9, 1
	addi $s0, $s0, 1			#increment $s0 for next register to store byte
	j compare
# REGISTER USAGE
# $s5: store the roman numeral value
	compare:				#keep find the next byte value and compare it with the previous if they are in descending order
	lb $s4, ($s0)					
	beq $s4, $s2, convert
	lb $t1, roman
	beq $s4, $t1, order11
	lb $t1, roman+1
	beq $s4, $t1, order22
	lb $t1, roman+2
	beq $s4, $t1, order33
	lb $t1, roman+3
	beq $s4, $t1, order44
	lb $t1, roman+4
	beq $s4, $t1, order55
	lb $t1, roman+5
	beq $s4, $t1, order66
	
		order11:
		addi $s5, $0, 1
		addi $t2, $t2, 1
		j checkpair11
			checkpair11:
			lb $t3, pair1
			addi $s0, $s0, 1
			lb $s4, ($s0)
			beq $s4, $t3, subtract11
			lb $t3, pair1+1
			beq $s4, $t3, subtract22
			bne $s4, $t3, comparecon
				subtract11:
				addi $s5, $0, 4
				addi $s0, $s0, 1 
				j comparecon
				subtract22:
				addi $s5, $0, 9
				addi $t7, $t7, 10
				addi $s0, $s0, 1
				j comparecon
				
		order22:
		addi $s5, $0, 5
		addi $t6, $t6, 1
		addi $s0, $s0, 1
		j comparecon
		
		order33:
		addi $s5, $0, 10
		addi $t7, $t7, 1
		j checkpair22
			checkpair22:
			lb $t3, pair2
			addi $s0, $s0, 1
			lb $s4, ($s0)
			beq $s4, $t3, subtract33
			lb $t3, pair2+1
			beq $s4, $t3, subtract44
			bne $s4, $t3, comparecon
				subtract33:
				addi $s5, $0, 40
				addi $s1, $s1, 50
				addi $s0, $s0, 1 
				j comparecon
				subtract44:
				addi $s5, $0, 90
				addi $t8, $t8, 100
				addi $s0, $s0, 1
				j comparecon
				
		order44:
		addi $s5, $0, 50
		addi $s1, $s1, 1
		addi $s0, $s0, 1
		j comparecon
		
		order55:
		addi $s5, $0, 100
		addi $t8, $t8, 1
		j checkpair33
			checkpair33:
			lb $t3, pair3
			addi $s0, $s0, 1
			lb $s4, ($s0)
			beq $s4, $t3, subtract55
			lb $t3, pair3+1
			beq $s4, $t3, subtract66
			bne $s4, $t3, comparecon
				subtract55:
				addi $s5, $0, 400
				addi $t9, $t9, 500
				addi $s0, $s0, 1 
				j comparecon
				subtract66:
				addi $s5, $0, 900
				addi $s0, $s0, 1
				j comparecon
	
		order66:
		addi $s5, $0, 500
		addi $t9, $t9, 1
		addi $s0, $s0, 1
		j comparecon
# REGISTER USAGE
# $s6: boolean outcome		
	comparecon:
	sle $s6, $s5, $s3			#$s5 stores the current value and $s3 stores the previous value and compare if they are in descending order
	add $s7, $s7, $s5
	move $s3, $s5				#set $s3 to the roman numeral value of the current byte
	beq $s6, 1, compare
	beq $s6, 0, error
# REGISTER USAGE
# $s6: store remainder
	convert:				#last check for any roman numeral exceed certain appear times
	bge $t2, 4, error			#$t2 stores the number of appear times for I
	rem $s6, $t7, 10
	bge $s6, 4, error			#$t7 stores the number of appear times for X without pair
	rem $s6, $t8, 100
	bge $s6, 4, error			#$t8 stores the number of appear times for C without pair
	bge $t6, 2, error			#$t6 stores the number of appear times for V
	rem $s6, $s1, 50
	bge $s6, 2, error			#$s1 stores the number of appear times for L without pair
	rem $s6, $t9, 500
	bge $s6, 2, error			#$t9 stores the number of appear times for D without pair
	j lastcheck
	
	lastcheck:					#compare to the largest roman numeral in argument, check if the sum of rest roman numeral is greater than largest roman numeral
		bne $t9, 0, lastcheckcon1		#If $t9 is greater than 0, then branch to lastcheckcon1
		bne $t8, 0, lastcheckcon2		#If $t8 is greater than 0, then branch to lastcheckcon1
		bne $s1, 0, lastcheckcon3		#If $s1 is greater than 0, then branch to lastcheckcon1
		bne $t7, 0, lastcheckcon4		#If $t7 is greater than 0, then branch to lastcheckcon1
		j convertcon2
# REGISTER USAGE
# $s1: store outcome of calculations	
# $s3: store outcome of calculations	
# $t7: store outcome of calculations	
# $t8: store outcome of calculations	
# $t9: store outcome of calculations		
			lastcheckcon1:			#calculate the sum of the rest roman numeral except the repeat D
			rem $t9, $t9, 500		
			mul $t9, $t9, 500
			sub $s3, $s7, $t9
			bgt $s3, 500, error
			j convertcon2
			
			lastcheckcon2:			#calculate the sum of the rest roman numeral except the repeat C
			rem $t8, $t8, 100
			mul $t8, $t8, 100
			sub $s3, $s7, $t8
			bgt $s3, 100, error
			j convertcon2
			
			lastcheckcon3:			#calculate the sum of the rest roman numeral except the repeat L
			rem $s1, $s1, 50
			mul $s1, $s1, 50
			sub $s3, $s7, $s1
			bgt $s3, 50, error
			j convertcon2
			
			lastcheckcon4:			#calculate the sum of the rest roman numeral except the repeat X
			rem $t7, $t7, 10
			mul $t7, $t7, 10
			sub $s3, $s7, $t7
			bgt $s3, 10, error
			j convertcon2
# REGISTER USAGE
# $s1: store value of 2 for calculation
# $s3: store outcome of calculations	
# $s4: store outcome of calculations	
# $s5: byte count
# $s6: store loaded byte		
	convertcon2:	
	addi $s1, $0, 2		#set $s1 to 2 for convert
	div $s3, $s7, $s1		#$s3 stores the outcome of $s7 divided by $s1
	rem $s4, $s7, $s1		#$s4 stores the remainder of $s7 divided by $s1
	addi $s4, $s4, 48		#add 48 to $s4 for print
	move $s5, $0			#reset $s5 to 0
	lb $s6, input($s5)		#load byte to $s6 for stores convert outcome
	add $s6, $s6, $s4		#add convert outcome to loaded byte
	sb $s6, input($s5)		#store the convert outcome to input memory address
	beq $s3, $0, print		#if the divide outcome is 0, call print
	j convert2
	
	convert2:
	rem $s4, $s3, $s1		#repeat the process of convertcon2 until all argument has been converted
	div $s3, $s3, $s1
	addi $s4, $s4, 48
	addi $s5, $s5, 1
	lb $s6, input($s5)
	add $s6, $s6, $s4
	sb $s6, input($s5)
	beq $s3, $0, print
	j convert2
	
	print:
	move $s5, $0
	li $v0, 4
	la $a0, newline
	syscall
	li $v0, 4
	la $a0, printmessage
	syscall
	li $v0, 4
	la $a0, printbinary
	syscall
	
		print2:				#load byte until reaches the null byte for print in correct order
		lb $s6, input($s5)
		beq $s6, $s2, printcon
		addi $s5, $s5, 1
		j print2
	
	printcon:				#print the outcome by printing the load byte from the end the input
	sub $s5, $s5, 1
	lb $s6, input($s5)
	beq $s6, $s2, stop			#stop print when reaches the null byte
	li $v0, 11
	la $a0, ($s6)
	syscall
	j printcon
	
	stop:
	li $v0, 4
	la $a0, newline
	syscall
	li $v0, 10
	syscall
	
	error: nop
	li $v0, 4
	la $a0, newline
	syscall
	li $v0, 4
	la $a0, message
	syscall
	li $v0, 10
	syscall
	nop
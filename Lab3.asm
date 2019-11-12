##########################################################################
# Created by:  Liang, Yixin
#
# Description: This program calculate the factorial of the number between 0 to 10 (include 0 and 10).
# 
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################

# In the main function {
#	print prompt "Enter an integer between 0 and 10: "
#	take a number from the user
#	check if the number is in range, if not, send to error function
#	check if the number equal to 0, if so, send to outcome1 function
#	check if the number equal to 10, if so, send to factorial function
#	}
#
#function error(){
#	print error message
#	back to main function and repeat asking until range satisfied
#	}
#
#function factorial(){
#     t4=t3; t4--
#     if(t4==0){
#        outcom1;
#    } else if(t4==1){
#        outcome2;    
#    }
#	t3 = t3*t4;
#	call factorial function recursively
#   outcome1:0/1!==1;
#   outcome2: t3=t3*t4 for calculation of any other number in range// in there t4=t3-1;
#   outcome1 & outcome2 print the result

.data
	ask: .asciiz "Enter an integer between 0 and 10: "
	newline: .asciiz "\n"
	errormessage: .asciiz "Invalid entry!\n"
.text
	main:
	li $v0, 4			  #$v0 stores the string type of values need to print
	la $a0, ask			  #$a0 load the value need to be printed
	syscall                         #print ask

	li $v0, 5			  #$v0 stores the values entered by the user
	syscall                         #read integer
	
	move $t4, $v0                   #copy the input to another register t4
	
	li $v0, 4
	la $a0, newline
	syscall	                       #print newline
	
	add $t1, $zero, 10             #set range, make t1 stores the value of 10
	
	move $t3, $t4                  #copy the input to two other register for factorial calculation
	move $t5, $t4			 #both of the register t5 and t3 stores the same value of t4
	
	slt $s0, $zero, $t4            #compare if input is greater than 0, s0 stores the comparison outcome of zero and t4
	slt $s1, $t4, $t1              #compare if input is less than 10, s1 store the comparison outcome of t4 and t1
	 
	and $s2, $s0, $s1              #check to see if it satify the range of 0 to 10, s2 stores the bitwise and output of s0 and s1
	
	beq $t4, $zero, outcome1        #if the input is 0, directly go to outcome1 since slt don't check if input equal to 0
	beq $t4, 10, factorial          #if the input is 10, directly go to factorial since slt don't check if input equal to 10
	beq $s2, $zero, error           #if comparison outcome is 0, go to error address
	beq $s2, 1, factorial           #if comparison outcome is 1, then go to factorial address for calculation
	
	error:
	
	li $v0, 4
	la $a0, errormessage
	syscall                         #print error message
	
	li $v0, 4
	la $a0, newline
	syscall                         #print newline
	
	j main                          #repreat compare process until the number is in range
	
	factorial:
	sub $t4, $t4, 1
	beq $t4, $zero, outcome1
	beq $t4, 1, outcome2
	mul $t3, $t3, $t4
	j factorial
	
	outcome1:
		li $v0, 1
		la $a0, ($t5)
		syscall
	
		li $v0, 11
		la $a0, 0x21
		syscall
	
		li $v0, 11
		la $a0, 0x20
		syscall
	
		li $v0, 11
		la $a0, 0x3D
		syscall
	
		li $v0, 11
		la $a0, 0x20
		syscall
	
		li $v0, 1
		la $a0, 1
		syscall
		
		
		li $v0, 4
		la $a0, newline
		syscall                     #print newline
	
		li $v0, 10
		syscall
	
	outcome2:
		li $v0, 1
		la $a0, ($t5)
		syscall
		
		li $v0, 11
		la $a0, 0x21
		syscall
		
		li $v0, 11
		la $a0, 0x20
		syscall
	
		li $v0, 11
		la $a0, 0x3D
		syscall
	
		li $v0, 11
		la $a0, 0x20
		syscall
		
		li $v0, 1
		la $a0, ($t3)
		syscall
		
		
		li $v0, 4
		la $a0, newline
		syscall                          #print newline
	
		li $v0, 10
		syscall                          #exit

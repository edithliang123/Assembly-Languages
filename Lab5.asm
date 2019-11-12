#-------------------------------------------------------------------------
# Created by:  Liang, Yixin
#
# Description: This program creates a gambling game that allow user to bet and record score
# 
# Notes:       This program is intended to be run from the MARS IDE.
#-------------------------------------------------------------------------

jal end_game                       # this is to prevent the rest of
                                   # the code executing unexpectedly

#--------------------------------------------------------------------
# play_game
#
# This is the highest level subroutine.
#
# arguments:  $a0 - starting score
#             $a1 - address of array index 0 
#
# return:     n/a
#--------------------------------------------------------------------

.text
play_game: nop
    move $t7, $a0							#set $t7 to the starting score
    move $t2, $0
    move $t0, $a1							#set $t0 to the address of array index 0
    arraysize: nop
    lw  $t1, ($t0)           						#use $a1 to get the number of elements in the array
    addi $t0, $t0, 4
    bne $t1, $0, arraysizecount                   
    
    move $a2, $t2							#set $a2 to array size before enter take_turn subroutine
    move $a0, $t2							#set $a0 to array size before enter welcome subroutine
    jal   welcome
    
   	 promptagain:
    		jal   prompt_options
    
    		move $a3, $v0						#set $a3 to user selection before enter take_turn subroutine
    		move $a0, $t7						#set $a0 to current score before enter take_turn subroutine
    		jal  take_turn
   		move $t8, $v0						#set $t8 to the updated score
    		j update
    
    jal   end_game
    
    jr    $ra
    
    arraysizecount:
    addi $t2, $t2, 1							#increment $t2 to calculate array size
    j arraysize

    update:
    move $t7, $t8							#set $t7 to the updated score
    j promptagain
#--------------------------------------------------------------------
# welcome (given)
#
# Prints welcome message indicating valid indices.
# Do not modify this subroutine.
#
# arguments:  $a0 - array size in words
#
# return:     n/a
#--------------------------------------------------------------------
#
# REGISTER USE
# $t0: array size
# $a0: syscalls
# $v0: syscalls
#--------------------------------------------------------------------

.data
welcome_msg: .ascii "------------------------------"
             .ascii "\nWELCOME"
             .ascii "\n------------------------------"
             .ascii "\n\nIn this game, you will guess the index of the maximum value in an array."
             .asciiz "\nValid indices for this array are 0 - "

end_of_msg:  .asciiz ".\n\n"
             
.text
welcome: nop

    add   $t0  $zero  $a0         # save address of array

    addiu $v0  $zero  4           # print welcome message
    la    $a0  welcome_msg
    syscall
    
    addiu $v0  $zero  1           # print max array index
    sub   $a0  $t0    1
    syscall

    addiu $v0  $zero  4           # print period
    la    $a0  end_of_msg
    syscall
    
    jr $ra
    
    
#--------------------------------------------------------------------
# prompt_options (given)
#
# Prints user options to screen.
# Do not modify this subroutine. No error handling is required.
# 
# return:     $v0 - user selection
#--------------------------------------------------------------------
#
# REGISTER USE
# $v0, $a0: syscalls
# $t0:      temporarily save user input
#--------------------------------------------------------------------

.data
turn_options: .ascii  "------------------------------" 
              .ascii  "\nWhat would you like to do? Select a number 1 - 3"
              .ascii  "\n"
              .ascii  "\n1 - Make a bet"
              .ascii  "\n2 - Cheat! Show me the array"
              .asciiz "\n3 - Quit before I lose everything\n\n"

.text
prompt_options: nop

    addiu $v0  $zero  4           # print prompts
    la    $a0  turn_options       
    syscall

    addiu $v0  $zero  5           # get user input
    syscall
    
    add   $t0  $zero  $v0         # temporarily saves user input to $t0
    
    addiu $v0  $zero  11
    addiu $a0  $zero  0xA         # print blank line
    syscall

    add   $v0  $zero  $t0         # return player selection
    jr    $ra


#--------------------------------------------------------------------
# take_turn	
#
# All actions taken in one turn are executed from take_turn.
#
# This subroutine calls one of following sub-routines based on the
# player's selection:
#
# 1. make_bet
# 2. print_array
# 3. end_game
#
# After the appropriate option is executed, this subroutine will also
# check for conditions that will lead to winning or losing the game
# with the nested subroutine win_or_lose.
# 
# arguments:  $a0 - current score
#             $a1 - address of array index 0 
#             $a2 - size of array (this argument is optional)
#             $a3 - user selection from prompt_options
#
# return:     $v0 - updated score
#--------------------------------------------------------------------
#
# REGISTER USE
# 
#--------------------------------------------------------------------

.text
take_turn: nop
    subi   $sp   $sp  4          					#push return addres to stack
    sw     $ra  ($sp)
    
    # some code
    move   $t8, $a0
    beq $a3, 2, choice2
    beq $a3, 3, choice3
    
    jal    make_bet
    move  $t8, $v0							#set $t8 to updated score
    beq   $t8, $0, solution						#if $t8 is 0, it match the condition to enter win_or_lose subroutine
    
    move $t3, $0  
    move $t0, $a1							#set $t0 to address of array index 0
    arraysize3: nop
    lw   $t1, ($t0)           	
    addi $t0, $t0, 4
    bne  $t1, $0, arraysizecount3
    
    move $t0, $a1
    lw   $t1, ($t0)  
    beq  $t1, $0, solution						#if the first elemnt is 0, it match the condition to enter win_or_lose subroutine
    bne  $t3, $0, prompt						#if not, go back and prompt the option again
    solution:
    move   $a0, $a1							#set $a0 to address of array index 0 before enter the subroutine
    move   $a1, $t8							#set $a1 to updated score before enter the subroutine
    jal    win_or_lose
    j choice3
    # some code
    choice2:
    move  $a0, $a1							#set $a0 to the address of the first element in array before enter print_array subroutine
    jal    print_array
    j prompt
    # some code
    choice3:
    jal    end_game

    prompt:
    move  $v0, $t8							#set $v0 to updated score before return
    
    lw    $ra  ($sp)            					#pop return address from stack
    addi  $sp   $sp   4
        
    jr $ra

    arraysizecount3:
    addi $t3, $t3, 1							#increment $t3 to calculate array size
    j arraysize3
    
#--------------------------------------------------------------------
# make_bet
#
# Called from take_turn.
#
# Performs the following tasks:
#
# 1. Player is prompted for their bet along with their index guess.
# 2. Max value in array and index of max value is determined.
#    (find_max subroutine is called)
# 3. Player guess is compared to correct index.
# 4. Score is modified
# 5. If player guesses correctly, max value in array is either:
#    --> no extra credit: replaced by -1
#    --> extra credit:    removed from array
#  
# arguments:  $a0 - current score of user
#             $a1 - address of first element in array
#
# return:     $v0 - updated score
#--------------------------------------------------------------------
#
# REGISTER USE
# 
#--------------------------------------------------------------------


.data
bet_header:   .ascii  "------------------------------"
              .asciiz "\nMAKE A BET\n\n"
            
score_header: .ascii  "------------------------------"
              .asciiz "\nCURRENT SCORE\n\n"
comment: .asciiz "You currently have "
comment2: .asciiz " points.\n"
comment3: .asciiz "How many points would you like to bet? "
newline2: .asciiz "\n"
beterror: .asciiz "\nSorry, your bet exceeds your current worth.\n\n"
askguess: .asciiz "Valid indices for this array are 0 - "
endask: .asciiz "."
askguess2: .asciiz "\nWhich index do you believe contains the maximum value? "
scorecomment: .asciiz "\nScore! Index "
scorecomment2: .asciiz " has the maximum value in the array.\n\n"
scorecomment3: .asciiz "You earned "
scorecomment4: .asciiz " points!\n"
scorecomment5: .asciiz "\nThis value has been removed from the array.\n\n"
minuscomment: .asciiz "\nYour guess is incorrect! The maximum value is not in index "
minuscomment2: .asciiz "\n\nYou lost "
currentscore: .asciiz " pts.\n\n"
newline4: .asciiz "\n"  
# add more strings

.text
make_bet: nop       
    
    subi   $sp   $sp  4
    sw     $ra  ($sp)

    move $t3, $0       			
    move $t0, $a1							#set $t0 to address of first element in array
    
    	arraysize2: nop
    	lw $t1, ($t0)           					#use $a1 to get the number of elements in the array
    	addi $t0, $t0, 4
    	bne $t1, $0, arraysizecount2

    move   $t9, $a0							#set $t9 to the current score
    
    addiu  $v0  $zero  4             					#print header
    la     $a0  bet_header
    syscall
    
    bet:
    addiu  $v0, $zero, 4
    la     $a0, comment
    syscall
    
    addiu  $v0, $zero, 1
    la     $a0, ($t9)
    syscall
    
    addiu  $v0, $zero, 4
    la     $a0, comment2
    syscall
    
    addiu  $v0, $zero, 4
    la     $a0, comment3
    syscall
    
    addiu  $v0, $zero, 5
    syscall
    
    move $t0, $v0							#set $t0 to the user bet value
   
    blt $t9, $t0, error						#compare user bet value with current score
    
    addiu  $v0, $zero, 4
    la     $a0, newline4
    syscall
    
    move $a0, $a1							#set $a0 to address of first element in array before enter the find_max subroutine
    jal find_max
    move $t1, $v0							#set $t1 to the max index
    move $t2, $v1							#set $t2 to the max value
    
    addiu  $v0  $zero  4
    la     $a0  askguess
    syscall
    
    addiu  $v0  $zero  1
    la     $a0  ($t3)
    syscall
    
    addiu  $v0  $zero  4
    la     $a0  endask
    syscall
    
    addiu  $v0  $zero  4
    la     $a0  askguess2
    syscall
    
    li 	   $v0, 5
    syscall

    move  $t3, $v0							#set $t3 to user bet index
    
    beq   $t3, $t1, score						#compare user bet index with max index
    bne   $t3, $t1, minus

    	score:
    	 	addiu  $v0  $zero  4
   	 	la     $a0  scorecomment
   	 	syscall
   	 
   	 	addiu  $v0  $zero  1
   	 	la     $a0  ($t1)
   	 	syscall
    	 
    	 	addiu  $v0  $zero  4
   		la     $a0  scorecomment2
   	 	syscall
   	 
   	 	addiu  $v0  $zero  4
   	 	la     $a0  scorecomment3
   	 	syscall

   	 	addiu  $v0  $zero  1
   	 	la     $a0  ($t0)
   	 	syscall
   	 
   	 	addiu  $v0  $zero  4
   	 	la     $a0  scorecomment4
   	 	syscall
   	 
   	 	addiu  $v0  $zero  4
   	 	la     $a0  scorecomment5
   	 	syscall
   	
   	 	add    $t4, $t9, $t0					#update score to register $t4
   	 
   	 	move   $t3, $a1
   	 
   	 		match: nop
   	 		lw     $t5, ($t3)				#load array value of certain array index to $t5
   	 		beq    $t5, $t2, fixarray
   	 		addi   $t3, $t3, 4
   	 		j match

   				fixarray: nop
   				addi   $t3, $t3, 4			
   				lw     $t6, ($t3)			#load array value of one index after the max index to $t6
   				beq    $t6, $0, fixarray2
   				subi   $t3, $t3, 4
   	 			sw     $t6, ($t3)			#store the next array value to the current array index
   	 			addi   $t3, $t3, 4
        			j fixarray
        		
        		fixarray2:
        		subi   $t3, $t3, 4				#set the last index to 0 after shifting array value
        		sw     $0,  ($t3)
        		j bet2
        	
        minus:
      	 	addiu  $v0  $zero  4
   		la     $a0  minuscomment
   	 	syscall
   	 
   	 	addiu  $v0  $zero  1
   	 	la     $a0  ($t3)
   	 	syscall
   	 
   	 	addiu  $v0  $zero  4
   		la     $a0  endask
   	 	syscall
   	 
   	 	addiu  $v0  $zero  4
   	 	la     $a0  minuscomment2
   	 	syscall
   	 
   	 	addiu  $v0  $zero  1
   	 	la     $a0  ($t0)
   	 	syscall
   	 
   	 	addiu  $v0  $zero  4
   	 	la     $a0  comment2
   	 	syscall
   	 
   	 	addiu  $v0  $zero  4
   	 	la     $a0  newline4
   	 	syscall
   	 
   	 	sub    $t4, $t9, $t0					#update score to register $t4
   	
   	 	j bet2
    
    bet2:
    addiu  $v0  $zero  4
    la     $a0  score_header
    syscall
    
    addiu  $v0  $zero  1
    la     $a0  ($t4)
    syscall
    
    addiu  $v0  $zero  4
    la     $a0  currentscore
    syscall
    
    move   $v0, $t4							#set $v0 to the update score as return value
    
    lw     $ra  ($sp)
    addi   $sp   $sp  4

    jr     $ra
    
    error:
    addiu  $v0, $zero, 4
    la     $a0, beterror
    syscall
    j bet
    
    arraysizecount2:
    addi $t3, $t3, 1							#increment $t3 to calculate array size
    j arraysize2

#--------------------------------------------------------------------
# find_max
#
# Finds max element in array, returns index of the max value.
# Called from make_bet.
# 
# arguments:  $a0 - address of first element in array
#
# returns:    $v0 - index of the maximum element in the array
#             $v1 - value of the maximum element in the array
#--------------------------------------------------------------------
#
# REGISTER USE
# 
#--------------------------------------------------------------------

.text
find_max: nop

    # some code
    move  $t1, $a0	       						#set $t1 to the address of first element in array
    move  $t3, $0
    move  $t5, $0
    lw  $t2, ($t1)							#set $t2 to the value of the first index of array
    
    max:
    addi $t1, $t1, 4
    lw $t4, ($t1)							#set $t4 to value of certain index of array
    beq $t4, $0, exit		
    
    	maxcon:
       addi $t3, $t3, 1						#set $t3 to increment index of array
       bge $t4, $t2, max2
       j max
    	
    max2:
    move $t2, $t4
    move $t5, $t3
    j max
    
    exit:
    move $v1, $t2
    move $v0, $t5

    jr     $ra


#--------------------------------------------------------------------
# win_or_lose
#
# After turn is taken, checks to see if win or lose conditions
# have been met
# 
# arguments:  $a0 - address of the first element in array
#             $a1 - updated score
#
# return:     n/a
#--------------------------------------------------------------------
#
# REGISTER USE
# 
#--------------------------------------------------------------------

.data
win_msg:  .ascii   "------------------------------"
          .asciiz  "\nYOU'VE WON! HOORAY! :D\n\n"

lose_msg: .ascii   "------------------------------"
          .asciiz  "\nYOU'VE LOST! D:\n\n"

.text
win_or_lose: nop
    beq   $a1, $0, lose						#if the current score is 0, jump to lose

    move $t3, $0
    move $t0, $a0							#set $t0 to the address of the first element in array
    
    arraysize4: nop							#calculate array size
    lw $t1, ($t0)           						
    addi $t0, $t0, 4
    bne $t1, $0, arraysizecount4
    
    beq $t3, $0, win							#if the array size is 0, jump to win
    bne $t3, $0, lose							#if the array size is not 0, jump to lose
    
    win:
    addiu  $v0  $zero  4
    la     $a0  win_msg
    syscall
    j end
    
    # some code
    lose:
    addiu  $v0  $zero  4
    la     $a0  lose_msg
    syscall
    
    end:
    jr     $ra

    arraysizecount4:
    addi $t3, $t3, 1							#increment $t3 to calculate array size
    j arraysize4

#--------------------------------------------------------------------
# print_array
#
# Print the array to the screen. Called from take_turn
# 
# arguments:  $a0 - address of the first element in array
#--------------------------------------------------------------------
#
# REGISTER USE
# $a0: syscalls
# $v0: syscalls
#--------------------------------------------------------------------

.data
cheat_header: .ascii  "------------------------------"
              .asciiz "\nCHEATER!\n\n"
column: .asciiz ": "
newline3: .asciiz "\n"
.text
print_array: nop
    move   $t3, $0
    move   $t2, $a0		      					#set $t2 to the address of the first element in array
    # some code
    
    addiu  $v0  $zero  4           					#print header
    la     $a0  cheat_header
    syscall
    
    lw    $t1, ($t2)
    
    printarray: nop         		
    	addiu $v0, $zero, 1
    	la    $a0, ($t3)
    	syscall
    	
    	addiu $v0, $zero, 4
    	la    $a0, column
    	syscall
    	
    	addiu $v0, $zero, 1
    	la    $a0, ($t1)
    	syscall
    	
    	addiu $v0, $zero, 4
    	la    $a0, newline3
    	syscall
    	
    	addi  $t2, $t2, 4
    	addi  $t3, $t3, 1
    	lw    $t1, ($t2)
    	bne   $t1, $0, printarray
    
    addiu $v0, $zero, 4
    la    $a0, newline3
    syscall
    
    jr     $ra


#--------------------------------------------------------------------
# end_game (given)
#
# Exits the game. Invoked by user selection or if the player wins or
# loses.
#
# arguments:  $a0 - current score
#
# returns:    n/a
#--------------------------------------------------------------------
#
# REGISTER USE
# $a0: syscalls
# $v0: syscalls
#--------------------------------------------------------------------

.data
game_over_header: .ascii  "------------------------------"
                  .ascii  " GAME OVER"
                  .asciiz " ------------------------------"

.text
end_game: nop

    add   $s0  $zero  $a0              # save final score

    addiu $v0  $zero  4                # print game over header
    la    $a0  game_over_header
    syscall
    
    addiu $v0  $zero  11               # print new line
    addiu $a0  $zero  0xA
    syscall
    
    addiu $v0  $zero  10               # exit program cleanly
    syscall


#--------------------------------------------------------------------
# OPTIONAL SUBROUTINES
#--------------------------------------------------------------------
# You are permitted to delete these comments.

#--------------------------------------------------------------------
# get_array_size (optional)
# 
# Determines number of 1-word elements in array.
#
# argument:   $a0 - address of array index 0
#
# returns:    $v0 - number of 1-word elements in array
#--------------------------------------------------------------------

#--------------------------------------------------------------------
# prompt_bet (optional)
#
# Prompts user for bet amount and index guess. Called from make_bet.
# 
# arguments:  $a0 - current score
#             $a1 - address of array index 0
#             $a2 - array size in words
#
# returns:    $v0 - user bet
#             $v1 - user index guess
#--------------------------------------------------------------------

#--------------------------------------------------------------------
# compare (optional)
#
# Compares user guess with index of largest element in array. Called
# from make_bet.
#
# arguments:  $a0 - player index guess
#             $a1 - index of the maximum element in the array
#
# return:     $v0 - 1 = correct guess, 0 = incorrect guess
#--------------------------------------------------------------------

#--------------------------------------------------------------------
# mod_score (optional)
#
# Modifies score based on outcome of comparison between user guess
# correct answer. Returns score += bet for correct guess. Returns
# score -= bet for incorrect guess. Called from make_bet.
# 
# arguments:  $a0 - current score
#             $a1 - player’s bet
#             $a2 - boolean value from comparison
#
# return:     $v0 - updated score
#--------------------------------------------------------------------

#--------------------------------------------------------------------
# mod_array (optional)
#
# Replaces largest element in array with -1 if player guessed correctly.
# Called from make_bet.
#
# If extra credit implemented, the largest element in the array is
# removed and array shrinks by 1 element. Index of largest element
# is replaced by another element in the array.
# 
# arguments:  $a0 - address of array index 0
#             $a1 - index of the maximum element in the array
# 
# return:     n/a
#--------------------------------------------------------------------

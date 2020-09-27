#3X3 MATRIX
.globl MAIN
.data
#Matrix dimension (length of rows and columns)
.eqv SIZE, 3
#Allocation of the matrix in bytes (SIZE*SIZE*4)
MATRIX: .space 36
#Array that contains size-1 elements and stores the indexes of already scanned numbers
MINOR_QUEUE: .space 8
OUTPUT_TEXT: .asciiz "\nThe determinant is "


.text
MAIN:
#Initializes the first argument to 0, which increments each time there's a recursion
li $a0, 0
la $a1, MINOR_QUEUE
la $s1, MATRIX
li $s0, SIZE

#Manually creating a 3x3 matrix
li $t0, 79 #(0,0)
li $t1, 78 #(0,1)
li $t2, 26 #(0,2)
li $t3, 74 #(1,0)
li $t4, 78 #(1,1)
li $t5, 96 #(1,2)
li $t6, 34 #(2,0)
li $t7, 85 #(2,1)
li $t8, 73 #(2,2)
sw $t0, 0($s1)
sw $t1, 4($s1)
sw $t2, 8($s1)
sw $t3, 12($s1)
sw $t4, 16($s1)
sw $t5, 20($s1)
sw $t6, 24($s1)
sw $t7, 28($s1)
sw $t8, 32($s1)
#Calculates the determinant
jal DETERMINANT
#Prints output
move $a0, $v0
jal PRINT_OUTPUT
jal PRINT

EXIT:
li $v0, 10
syscall

DETERMINANT:
#Checks the dimension of the matrix, if it's equal to one (rows - ind == 1),
#it returns the current single element
sub $t0, $s0, $a0
bne $t0, 1, MINOR
li $t0, 0 #Initializes counter to 0
SINGLE_ELEMENT_LOOP: #for begins
subi $sp, $sp, 12
sw $a0, 0($sp)
sw $a1, 4($sp)
sw $ra, 8($sp)
#Arranges arguments correctly
move $a0, $a1
lw $a1, 0($sp)
move $a2, $t0
#Calls the IS_IN function
jal IS_IN
lw $a0, 0($sp)
lw $a1, 4($sp)
lw $ra, 8($sp)
addi $sp, $sp, 12
bnez $v0, SINGLE_ELEMENT_END

#Multiplies the first argument per the matrix size
mult $a0, $s0
mflo $t1
#Then sums it to i
add $t1, $t1, $t0
#Multiplies by four
sll $t1, $t1, 2
#Adds it to the base address to retrieve the correct element
add $t1, $s1, $t1
lw $v0, 0($t1)
jr $ra

SINGLE_ELEMENT_END:
addi $t0, $t0, 1
j SINGLE_ELEMENT_LOOP

MINOR:
#Initializes two temporary variables to 1, representing the indexes of a scanned element
li $t1, 1
li $t2, 1
li $t0, 0 #Initializes loop counter to 0
li $v0, 0

MINOR_LOOP:
beq $t0, $s0, MINOR_EXIT #Loop condition
subi $sp, $sp, 16
sw $a0, 0($sp)
sw $a1, 4($sp)
sw $ra, 8($sp)
sw $v0, 12($sp)
#Arranges arguments correctly
move $a0, $a1
lw $a1, 0($sp)
move $a2, $t0
#Calls the IS_IN function
jal IS_IN
move $t3, $v0
lw $a0, 0($sp)
lw $a1, 4($sp)
lw $ra, 8($sp)
lw $v0, 12($sp)
addi $sp, $sp, 16

bnez $t3, MINOR_END
sll $t3, $a0, 2
add $t3, $a1, $t3
sw $t0, 0($t3) #Sets the minor queue element located at 'recursive counter' to the loop counter

subi $sp, $sp, 24
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $t2, 8($sp)
sw $a0, 12($sp)
sw $ra, 16($sp)
sw $v0, 20($sp)
addi $a0, $a0, 1
jal DETERMINANT
#Caches the result of determinant in t5
move $t5, $v0
lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $a0, 12($sp)
lw $ra, 16($sp)
lw $v0, 20($sp)
addi $sp, $sp, 24

add $t3, $t1, $t2
li $t4, 2
div $t3, $t4
mfhi $t3

bnez $t3, ODD_IND
#Multiplies the first argument per the matrix size
mult $a0, $s0
mflo $t3
#Then sums it to i
add $t3, $t3, $t0
#Multiplies by for
sll $t3, $t3, 2
#Adds it to the base address to retrieve the correct element
add $t3, $s1, $t3
lw $t3, 0($t3)
#Applies Laplace algorithm (even sum of indexes)
mult $t3, $t5
mflo $t3
add $v0, $v0, $t3
j IF_END

ODD_IND:
#Multiplies the first argument per the matrix size
mult $a0, $s0
mflo $t3
#Then sums it to the counter
add $t3, $t3, $t0
#Multiplies by four
sll $t3, $t3, 2
#Adds it to the base address to retrieve the correct element
add $t3, $s1, $t3
lw $t3, 0($t3)
#Applies Laplace algorithm (odd sum of indexes)
mult $t3, $t5
mflo $t3
sub $v0, $v0, $t3

IF_END:
addi $t2, $t2, 1 #Increments the column counter value
MINOR_END:
addi $t0, $t0, 1 #Increments the loop counter
j MINOR_LOOP

MINOR_EXIT:
jr $ra

#Function that checks if a given number is in the given array
IS_IN:
#Caches temporary variables
subi $sp, $sp, 8
sw $t0, 0($sp)
sw $t1, 4($sp)
li $t0, 0 #Counter variable set to 0
#Multiply size by four
sll $a1, $a1, 2
IS_IN_LOOP:
beq $t0, $a1, IS_IN_RETURN_FALSE #Loop condition, returns false at the end of it
#Increment address value by four to scan all elements
add $a0, $a0, $t0 
lw $t1, 0($a0) 
beq $a2, $t1, IS_IN_RETURN_TRUE #If the current element is equal to the argument it returns 1
addi $t0, $t0, 4 #Increment counter
j IS_IN_LOOP
IS_IN_RETURN_FALSE:
lw $t0, 0($sp)
lw $t1, 4($sp)
addi $sp, $sp, 8
li $v0, 0
jr $ra
IS_IN_RETURN_TRUE:
lw $t0, 0($sp)
lw $t1, 4($sp)
addi $sp, $sp, 8
li $v0, 1
jr $ra

#Printing functions
PRINT:
subi $sp, $sp, 4
sw $v0, 0($sp)
li $v0, 1
syscall
lw $v0, 0($sp)
addi $sp, $sp, 4
jr $ra

PRINT_OUTPUT:
subi $sp, $sp, 8
sw $v0, 0($sp)
sw $a0, 4($sp)
li $v0, 4
la $a0, OUTPUT_TEXT
syscall
lw $v0, 0($sp)
lw $a0, 4($sp)
addi $sp, $sp, 8
jr $ra

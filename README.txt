1. compile assignment2.y file using the command bison -d assignment2.y
	There would be some conflicts, please ignore them.

2. compile assignment2.l file using the command flex assignment2.l

3. Now compile 2 file using the command gcc assignment2.tab.c lex.yy.c -o y.exe -w
	The executable y.exe will be generated.

4. execute y.exe

5. write the C code line by line.

6. The program will stop executing as soon as it finds the first syntax or semantic error. if it doesn't stop, refer point 8.

7. run the program again and this time remove that error in which the program stopped last time to check the next error.

8. When the program detects an syntax error and does not stop automatically, 
kill the program and execute again after removing that error.

9. if the program shows error for the line which doesn't contain error then remove that line when executing again to see 
  it can find next error.


SPECIAL CASES:

1. If while generating three address code for any expression, the program gives syntax error. Then, please use brackets in that expression.

2. While generating three address code for "if" statement, it will give a extra variable(temp) as output and is assigned 1. It is not an error
	but is used to check whether "else" statement should be executed.  

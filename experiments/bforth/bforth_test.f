: asserteq = 0= if ." Assertion failed, values are not equal" 1 exit then ;
: ASSERTEMPTY depth 0= if ." Assertion failed, stack is not empty" 1 exit then;

( test arithmetic )
2 3 * 6 asserteq assertempty
2 3 + 5 asserteq assertempty
2 3 - -1 asserteq assertempty
6 3 / 2 asserteq assertempty

( test allot )
HERE 0 asserteq
5 ALLOT
here 5 asserteq
-3 allot
here 2 asserteq
assertempty

( test constant )
123 constant x123
x123 123 ASSERTEQ
assertempty

( test variable )
variable v1
1234 v1 !
v1 @ 1234 asserteq 
assertempty

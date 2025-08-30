( Unit tests )

: asserteq over over = 0= if ." Assertion failed, values are not equal: " . ." !=" . cr 1 exit else drop drop then ;
: fasserteq over over = 0= if ." Assertion failed, values are not equal: " f. ." !=" f. cr 1 exit else drop drop then ;
: ASSERTEMPTY depth 0 > if ." Assertion failed, stack is not empty: " .s 1 cr exit then ;

." test arithmetic" cr
2 3 * 6 asserteq
2 3 + 5 asserteq
2 3 - -1 asserteq
6 3 / 2 asserteq
assertempty

." test allot" cr
HERE 0 asserteq
5 ALLOT
here 5 asserteq
-3 allot
here 2 asserteq
assertempty

." test constant" cr
123 constant x123
x123 123 ASSERTEQ
assertempty

." test variable" cr
variable v1
variable v2
variable v3
1234 v1 !
100 v2 !
1000 v3 !
v1 @ v2 @ v3 @ + + 2334 asserteq 
assertempty

." test DO ... LOOP" cr
0 10 0 do 2 + loop 20 asserteq
assertempty

." test BEGIN ... UNTIL" cr
10 begin 1 - dup 0= until 0 asserteq
assertempty

." test fixed-point" cr
1.234 1234000 asserteq
.234 234000 asserteq
1. 1000000 asserteq
99.123456 99123456 fasserteq
1.22 2.11 f+ 3.33 fasserteq
1.22 2.11 f- -0.89 fasserteq
2. 2.5 f* 5. fasserteq
10. 2. f/ 5. fasserteq
10. 3. f/ 3.333333 fasserteq
10. 8. f/ 1.25 fasserteq
assertempty

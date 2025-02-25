% Special Pythagorean Triplet
%
% A Pythagorean triplet is a set of three natural numbers, a < b < c, for which, a^2 + b^2 = c^2
%
% There exists exactly one Pythagorean triplet for which a + b + c = 1000.
% Find the product abc.
:- use_module(library(clpz)).

triplet(A, B, C) :-
    0 #< A,
    A #< B,
    B #< C,
    A * A + B * B #= C * C.

run :- triplet(A,B,C), 1000 #= A + B + C, [A,B,C] ins 1..1000, label([A,B,C]), P #= A * B * C, write(P).

:- initialization(run).
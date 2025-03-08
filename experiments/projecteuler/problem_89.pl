:- use_module(library(dcgs)).
:- use_module(library(clpz)).
:- use_module(library(pio)).
:- use_module(library(lists)).
:- use_module(library(format)).

lines([]) --> call(eos), !.
lines([Line|Lines]) --> line(Line), lines(Lines).
eos([], []).
line([]) --> ( "\n" ; call(eos) ), !.
line([L|Ls]) --> [L], line(Ls).

roman(N) --> roman_(N, [m, cm, d, cd, c, xc, l, xl, x, ix, v, iv, i]).
roman_(0, _) --> "".
roman_(N, Options) --> { N #>= 1000, member(m, Options) }, "M", { N1 #= N - 1000 }, roman_(N1, [m, cm, d, cd, c, xc, l, xl, x, ix, v, iv, i]).
roman_(N, Options) --> { N #>= 900, member(cm, Options) }, "CM", { N1 #= N - 900 }, roman_(N1, [d, cd, c, xc, l, xl, x, ix, v, iv, i]).
roman_(N, Options) --> { N #>= 500, member(d, Options) }, "D", { N1 #= N - 500 }, roman_(N1, [c, xc, l, xl, x, ix, v, iv, i]).
roman_(N, Options) --> { N #>= 400, member(cd, Options) }, "CD", { N1 #= N - 400 }, roman_(N1, [c, xc, l, xl, x, ix, v, iv, i]).
roman_(N, Options) --> { N #>= 100, member(c, Options) }, "C", { N1 #= N - 100 }, roman_(N1, [c, xc, l, xl, x, ix, v, iv, i]).
roman_(N, Options) --> { N #>= 90, member(xc, Options) }, "XC", { N1 #= N - 90 }, roman_(N1, [l, xl, x, ix, v, iv, i]).
roman_(N, Options) --> { N #>= 50, member(l, Options) }, "L", { N1 #= N - 50 }, roman_(N1, [x, ix, v, iv, i]).
roman_(N, Options) --> { N #>= 40, member(xl, Options) }, "XL", { N1 #= N - 40 }, roman_(N1, [x, ix, v, iv, i]).
roman_(N, Options) --> { N #>= 10, member(x, Options) }, "X", { N1 #= N - 10 }, roman_(N1, [x, ix, v, iv, i]).
roman_(N, Options) --> { N #= 9, member(ix, Options) }, "IX".
roman_(N, Options) --> { N #>= 5, member(v, Options) }, "V", { N1 #= N - 5 }, roman_(N1, [i]).
roman_(N, Options) --> { N #= 4, member(iv, Options) }, "IV".
roman_(N, Options) --> { N #> 0, member(i, Options) }, "I", { N1 #= N - 1 }, roman_(N1, [i]).

rewrite_roman(Rs, Rs1, D) :- 
    phrase(roman(N), Rs), 
    integer(N), 
    phrase(roman(N), Rs1), !,
    length(Rs, D0),
    length(Rs1, D1),
    D is D1 - D0.

rewrite_with_diff(Rs, N) :-
    rewrite_roman(Rs, Rs1, N),
    format("~s -> ~s: ~d~n", [Rs, Rs1, N]).

problem_89 :- 
    phrase_from_file(lines(Ls), 'experiments/projecteuler/0089_roman.txt'),
    maplist(rewrite_with_diff, Ls, Ds),
    sum_list(Ds, Sum),
    format("~d~n", [Sum]),
    halt.

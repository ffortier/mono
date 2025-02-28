:- use_module(library(pairs)).
:- use_module(library(dcgs)).
:- use_module(library(iso_ext)).
:- use_module(library(clpz)).

lattice_path(N, N-N) --> [].
lattice_path(N, X-Y) --> { X #< N, X1 #= X + 1 }, "R", lattice_path(N, X1-Y).
lattice_path(N, X-Y) --> { Y #< N, Y1 #= Y + 1 }, "D", lattice_path(N, X-Y1).

find_path(N, P) :- phrase(lattice_path(N, 0-0), P).

problem_15_ :- countall(find_path(2, _), N), write(N), nl, halt.
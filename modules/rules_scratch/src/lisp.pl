% Custom lisp parser tailored to this project needs
% Inspired by https://www.metalevel.at/lisprolog/

:- module(lisp, [sexprs/3]).

:- use_module(library(dcgs)).
:- use_module(library(charsio)).
:- use_module(library(lists)).

sexprs([E|Es]) -->
    ws, sexpr(E), ws,
    !, % single solution: longest input match
    sexprs(Es).
sexprs([]) --> [].

ws --> [W], { char_type(W, whitespace) }, ws.
ws --> [].

sexpr(s(A))  --> symbol(Cs), { atom_chars(A, Cs) }.
sexpr(n(N))  --> number(Cs), { number_chars(N, Cs) }.
sexpr(z(Cs)) --> ['"'], seq(Cs), ['"'].
sexpr(List)  --> "(", sexprs(List), ")".

number([D|Ds]) --> digit(D), number(Ds).
number([D])    --> digit(D).

digit(D) --> [D], { char_type(D, decimal_digit) }.

symbol([A|As]) -->
    [A],
    { memberchk(A, "+/-*><=") ; char_type(A, alpha) },
    symbolr(As).

symbolr([A|As]) -->
    [A],
    { memberchk(A, "+/-*><=") ; char_type(A, alnum) },
    symbolr(As).
symbolr([]) --> [].

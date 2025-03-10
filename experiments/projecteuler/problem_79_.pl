:-use_module(library(lists)).
:-use_module(library(dcgs)).

passcode([]) --> [].
passcode([K | Ks]) --> [K], passcode(Ks).
passcode(Ks) --> [I], { member(I, [0,1,2,3,4,5,6,7,8,9]) }, passcode(Ks).

keylog_numbers([], []).
keylog_numbers([K | Ks], Ns) :- number_chars(N, [K]), keylog_numbers(Ks, Ns0), append([N], Ns0, Ns).

all_valid([], _).
all_valid([K | Ks], Passcode) :- phrase(passcode(K), Passcode), all_valid(Ks, Passcode).

problem_79_ :-
    Keylog0 = ["319", "680", "180", "690", "129", "620", "762", "689", "762", "318", "368", "710", "720", "710", "629", "168", "160", "689", "716", "731", "736", "729", "316", "729", "729", "710", "769", "290", "719", "680", "318", "389", "162", "289", "162", "718", "729", "319", "790", "680", "890", "362", "319", "760", "316", "729", "380", "319", "728", "716"],
    maplist(keylog_numbers, Keylog0, Keylog),
    all_valid(Keylog, [7,3,1,6,2,8,9,0]),
    halt.

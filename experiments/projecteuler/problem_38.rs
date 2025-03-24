use std::{collections::HashSet, hash::RandomState};

fn is_pandigital(s: &str, digits: &str) -> bool {
    let mut digits: HashSet<char, RandomState> = HashSet::from_iter(digits.chars());

    for ch in s.chars() {
        if !digits.remove(&ch) {
            return false;
        }
    }

    true
}

fn main() {
    let mut max = 0;

    for i in 0..10000 {
        let mut n = i;
        let mut buf = String::new();

        loop {
            let previous_len = buf.len();

            buf.extend(n.to_string().chars());

            if !is_pandigital(&buf, "123456789") {
                buf.truncate(previous_len);
                break;
            }

            n += i;
        }

        if buf.len() == 9 {
            dbg!((i, n / i - 1, &buf));

            let num = buf.parse().expect("Expected valid number");

            if num > max {
                max = num;
            }
        }
    }

    println!("{max}");
}

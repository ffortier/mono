open System

let insert_with_permutations (n: int) (arr: int list) = seq {
    for i in 0..List.length arr do
        yield List.insertAt i n arr
}

let rec pandigital (n: int) (digits: int list) = 
    match n with
    | 0 -> seq {digits}
    | _ -> insert_with_permutations n digits
           |> Seq.map (pandigital (n - 1)) 
           |> Seq.concat

let make_num (digits: int list) =
    let rec make_num_ (digits: int list) (n: int) =
        match digits with
        | [] -> n
        | d :: digits' -> make_num_ digits' (n * 10 + d)

    make_num_ digits 0

let group_numbers (digits: int list) = seq {
    let n = List.length digits
    let first_n = int (Math.Floor ((decimal n) / 3.0m))

    for f in 0..first_n - 1 do
        let second_n = int (Math.Floor (((decimal n) - (decimal f)) / 2.0m))
        for s in f + 1..f + second_n do
            let a = digits[0..f] |> make_num
            let b = digits[f+1..s] |> make_num
            let c = digits[s+1..] |> make_num

            yield (a, b, c)
}

pandigital 9 []
|> Seq.map group_numbers
|> Seq.concat
|> Seq.filter (fun (a, b, c) -> a < b && b < c)
|> Seq.filter (fun (a, b, c) -> a * b = c)
|> Seq.map (fun (_, _, c) -> c)
|> Seq.sort
|> Seq.distinct
|> Seq.sum
|> printfn "%A"

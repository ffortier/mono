open System

let is_prime (n: int) =
    match n with
    | 2 -> true
    | n -> match [| 2..int (sqrt (float n)) + 1 |] |> Array.tryFind (fun i -> n % i = 0) with
           | Some _ -> false
           | None -> true

let primes (m: int) = 
    [| 2..m |]
    |> Array.Parallel.filter is_prime

let order (n: int) =
    let mutable x = 0
    while pown 10 x <= n do x <- x + 1
    x

let ror (n: int) =
    let u = n % 10
    let b = n / 10
    b + (pown 10 (order b)) * u

let rearrange (n: int) =
    let rec rearrange_ (n: int) (m: int) (left: int) =
        match left with
        | 0 -> m
        | _ -> rearrange_ (ror n) (max m n) (left - 1)

    rearrange_ n n (order n)

let cardinality arr = seq {
    let mutable cur = 0
    let mutable count = 0
    for x in arr do
        if x <> cur then
            if count > 0 then yield (cur, count)
            cur <- x
            count <- 1
        else
            count <- count + 1
    if count > 0 then yield (cur, count)
}

let all_same_digits (n: int) =
    (ror n) = n

primes 1000000
|> Array.Parallel.map rearrange
|> Array.Parallel.sort
|> cardinality
|> Seq.map (fun tuple -> 
    match tuple with 
    | n, card when (order n) = card -> card 
    | n, 1 when all_same_digits n -> 1
    | _ -> 0)
|> Seq.sum
|> printfn "%A"

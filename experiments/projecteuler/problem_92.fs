open System
open System.Collections.Generic

let split_digits (n: int) = seq {
    let mutable cur = n

    while cur > 0 do
        yield cur % 10
        cur <- cur / 10
}

let rec compute (n: int) =
    match n with
    | 1 -> 1
    | 89 -> 89
    | n ->
        split_digits n
        |> Seq.map (fun n -> n * n)
        |> Seq.sum
        |> compute

[| 1..10000000 |]
|> Array.Parallel.map compute
|> Array.Parallel.filter (fun n -> n = 89)
|> Array.length
|> printfn "%A" 

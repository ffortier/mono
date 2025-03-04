open System

let collatz (n: int64) =
    let rec collatz_ (n: int64) (len: int64) =
        if n = 1 then len
        else if (n &&& 1) = 0 then collatz_ (n / 2L) (len + 1L)
        else collatz_ (3L * n + 1L) (len + 1L)

    collatz_ n 1

[| 1L..1000000L |]
|> Array.Parallel.map (fun n -> n, collatz n)
|> Array.maxBy (fun s -> match s with | (_, value) -> value)
|> printfn "%A"
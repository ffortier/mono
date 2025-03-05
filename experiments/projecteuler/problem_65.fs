open System

let factors_e = seq {
    yield 2I

    let mutable cur = 2I

    while true do
        yield 1I
        yield cur
        yield 1I
        cur <- cur + 2I
}

let compute (frac: bigint * bigint) (factor: bigint) = 
    match frac with
    | denominator, numerator -> (factor * denominator + numerator, denominator)
    

let convergents (n: int) (s: bigint seq) =
    s
    |> Seq.take n
    |> Seq.rev
    |> Seq.fold compute (1I, 0I) 


let split_digits (n: bigint) = seq {
    let mutable cur = n

    while cur > 0I do
        yield cur % 10I
        cur <- cur / 10I
}

let numerator (frac: bigint * bigint) = match frac with | numerator, _ -> numerator

factors_e
|> convergents 100
|> numerator
|> split_digits
|> Seq.sum
|> printfn "%A"

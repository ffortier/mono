open System

let days_in_month (y: int) (m: int) =
    match m with
    | 2 when (y % 4 = 0 && y % 100 <> 0) || y % 400 = 0 -> 29
    | 2 -> 28
    | 4 | 6 | 9 | 11 -> 30
    | _ -> 31
 
let sundays =
    (1900, 1, 7)
    |> Seq.unfold (fun state -> 
        let y, m, d = state
        let d' = ((d + 6) % (days_in_month y m)) + 1
        let m' = if d' < d then (m % 12) + 1 else m
        let y' = if m' = 1 && m = 12 then y + 1 else y

        Some((y, m, d), (y', m', d'))
    )
    |> Seq.filter (fun el ->
        let y, m, d = el
        y >= 1901 && d = 1
    )
    |> Seq.takeWhile (fun el -> 
        let y, m, d = el
        y <= 2000
    )
    |> Seq.length
    |> printfn "%A"
    
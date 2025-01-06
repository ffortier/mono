import { Predecessor, Successor, ParseInt } from './num.ts';

type State = 0 | 1;

type LivingCells<Board extends {}> = {
    [Row in keyof Board]: Board[Row] extends unknown[] ? {
        [Col in Extract<keyof Board, keyof Board[Row]>]: Board[Row][Col] extends 1 ? [ParseInt<Row>, ParseInt<Col>] : never;
    }[Extract<keyof Board, keyof Board[Row]>] : never
}[keyof Board];

type Sum<Bs extends boolean[], S extends number = 0>
    = Bs extends [] ? S
    : Bs extends [true, ...infer Bs1] ? Bs1 extends boolean[] ? Sum<Bs1, Successor<S>> : never
    : Bs extends [false, ...infer Bs1] ? Bs1 extends boolean[] ? Sum<Bs1, S> : never
    : never;

type CountNeighbours<Cells, Row extends number, Col extends number>
    = Sum<[
        [Predecessor<Row, number, -1>, Predecessor<Col, number, -1>] extends Cells ? true : false,
        [Predecessor<Row, number, -1>, Col] extends Cells ? true : false,
        [Predecessor<Row, number, -1>, Successor<Col, number, -1>] extends Cells ? true : false,
        [Successor<Row, number, -1>, Predecessor<Col, number, -1>] extends Cells ? true : false,
        [Successor<Row, number, -1>, Col] extends Cells ? true : false,
        [Successor<Row, number, -1>, Successor<Col, number, -1>] extends Cells ? true : false,
        [Row, Predecessor<Col, number, -1>] extends Cells ? true : false,
        [Row, Successor<Col, number, -1>] extends Cells ? true : false,
    ]>

type ApplyRulesOnLiving<LivingNeighbourCount>
    = LivingNeighbourCount extends 2 ? 1
    : LivingNeighbourCount extends 3 ? 1
    : 0

type ApplyRulesOnDead<LivingNeighbourCount>
    = LivingNeighbourCount extends 3 ? 1
    : 0

type ApplyRules<Livings, Row extends number, Col extends number, Current extends State>
    = Current extends 1 ? ApplyRulesOnLiving<CountNeighbours<Livings, Row, Col>>
    : ApplyRulesOnDead<CountNeighbours<Livings, Row, Col>>

type ScanRow<Board extends {}, Row extends keyof Board, Livings, Cells extends State[] = []>
    = Cells['length'] extends keyof Board[Row] ? Board[Row][Cells['length']] extends State ? ScanRow<Board, Row, Livings, [...Cells, ApplyRules<Livings, ParseInt<Row>, Cells['length'], Board[Row][Cells['length']]>]> : Cells
    : Cells;

export type Gol<Board extends {}> = {
    [Row in keyof Board]: ScanRow<Board, Row, LivingCells<Board>>
}

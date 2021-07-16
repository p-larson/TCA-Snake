import Foundation

public struct Direction: Equatable, Hashable {
    let dx, dy: Int
}

extension Direction {
    static let left = Direction(dx: -1, dy: 0)
    static let down = Direction(dx: 0, dy: -1)
    static let up = Direction(dx: 0, dy: 1)
    static let right = Direction(dx: 1, dy: 0)
    static let all: [Direction] = [.left, .down, .up, .right]
}

func +(rhs: Coordinate, lhs: Direction) -> Coordinate {
    Coordinate(row: rhs.row + lhs.dx, column: rhs.column + lhs.dy)
}

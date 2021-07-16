import Foundation
import ComposableArchitecture

public struct GameState: Equatable, Hashable {
    var player: [Coordinate]
    var food: Coordinate = Coordinate(row: 5, column: 0)
    var direction: Direction = Direction.right
    var isPlaying: Bool = false
    var rows, columns: Int
    var timer: AnyHashable? = nil
    var gameoverAlertState: AlertState<GameAction>? = nil
    
    public init(initialPosition: Coordinate, rows : Int, columns: Int) {
        self.player = [initialPosition]
        self.rows = rows
        self.columns = columns
    }
}

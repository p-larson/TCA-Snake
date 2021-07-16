import Foundation
import ComposableArchitecture

public let gameReducer = Reducer<GameState, GameAction, GameEnvironment> { state, action, environment in
    switch action {
    case .reset:
        state.player = [newPlayerSpawn(rows: state.rows, columns: state.columns)]
        state.food = findOpenCoordinate(player: state.player, rows: state.rows, columns: state.columns)!
        state.direction = safeDirection(from: state.player.first!, rows: state.rows, columns: state.columns)
        
        return .none
    case .start:
        state.timer = TimerID()
        
        return Effect.timer(
            id: state.timer!,
            every: .milliseconds(100),
            on: environment.mainQueue
        )
            .eraseToEffect()
            .map { _ in GameAction.tick }
    case .tick:
        let nextCoordinate = state.player.first! + state.direction
        
        guard isInBounds(coordinate: nextCoordinate, rows: state.rows, columns: state.columns) else {
            return Effect(value: .end)
        }
        
        state.player.insert(nextCoordinate, at: state.player.startIndex)
        
        if nextCoordinate != state.food {
            state.player.removeLast()
        } else {
            if let openCoordinate = findOpenCoordinate(
                player: state.player,
                rows: state.rows,
                columns: state.columns
            ) {
                state.food = openCoordinate
            } else {
                return Effect(value: .end)
            }
        }
        
        return .none
    case .eatFood:
        return Effect(value: .spawnFood)
    case .spawnFood:
        if let openCoordinate = findOpenCoordinate(
            player: state.player,
            rows: state.rows,
            columns: state.columns
        ) {
            state.food = openCoordinate
            
            return .none
        } else {
            return Effect(value: .end)
        }
    case .end:
        state.isPlaying = false
        state.gameoverAlertState = AlertState(
            title: TextState("Game Over"),
            message: nil,
            dismissButton: .default(
                TextState("Play Again"),
                send: .reset
            )
        )
        
        defer {
            state.timer = nil
        }
                
        return Effect.cancel(id: state.timer!)
    case let .change(direction):
        
        state.direction = direction
        
        return !state.isPlaying && state.timer == nil ? Effect(value: .start) : .none
    case .actionSheetDismiss:
        state.gameoverAlertState = nil
        return .none
    }
}

// MARK: ID
fileprivate struct TimerID: Hashable {}

// MARK: Util

fileprivate func newPlayerSpawn(rows: Int, columns: Int) -> Coordinate {
    // Get a random coordinate on the perimeter of the map, inset by 1.
    let insetRows = 1 ..< rows - 1
    let insetColumns = 1 ..< columns - 1
    
    if Bool.random() {
        return Coordinate(
            row: Bool.random() ? insetRows.first! : insetRows.last!,
            column: insetColumns.randomElement()!
        )
    } else {
        return Coordinate(
            row: insetRows.randomElement()!,
            column: Bool.random() ? insetColumns.first! : insetColumns.last!
        )
    }
}

// Really not the most efficient piece of code theoretically... oops :)
fileprivate func findOpenCoordinate(player: [Coordinate], rows: Int, columns: Int) -> Coordinate? {
    guard player.count != rows * columns else {
        return nil
    }
    
    while true {
        let coordinate = Coordinate(
            row: Int.random(in: 0 ..< rows),
            column: Int.random(in: 0 ..< columns)
        )
        
        if !player.contains(coordinate) {
            return coordinate
        }
    }
}

fileprivate func isInBounds(coordinate: Coordinate, rows: Int, columns: Int) -> Bool {
    (0 ..< rows).contains(coordinate.row) && (0 ..< columns).contains(coordinate.column)
}

fileprivate func safeDirection(from coordinate: Coordinate, rows: Int, columns: Int) -> Direction {
    while true {
        let direction = Direction.all.randomElement()!
        
        let doubleMove = coordinate + direction + direction
        
        if isInBounds(coordinate: doubleMove, rows: rows, columns: columns) {
            return direction
        }
    }
}

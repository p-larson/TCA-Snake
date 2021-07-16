import Foundation

public enum GameAction: Equatable, Hashable {
    case reset
    case start
    case tick
    case end
    case eatFood
    case spawnFood
    case change(Direction)
    case actionSheetDismiss
}

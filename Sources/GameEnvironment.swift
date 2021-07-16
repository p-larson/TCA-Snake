import Dispatch
import ComposableArchitecture

public struct GameEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

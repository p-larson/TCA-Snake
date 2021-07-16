//
//  TCASnakeApp.swift
//  Shared
//
//  Created by Peter Larson on 7/11/21.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCASnakeApp: App {
    var body: some Scene {
        WindowGroup {
            GameView(
                store: Store(
                    initialState: GameState(
                        initialPosition: Coordinate(row: 0, column: 0),
                        rows: 30,
                        columns: 60
                    ),
                    reducer: gameReducer.debug(),
                    environment: GameEnvironment(
                        mainQueue: DispatchQueue
                            .main
                            .eraseToAnyScheduler()
                    )
                )
            )
        }
    }
}

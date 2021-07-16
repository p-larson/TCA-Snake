import ComposableArchitecture
import SwiftUI

struct GameView: View {
	// Dependencies
	let store: Store<GameState, GameAction>
	
	public var body: some View {
		WithViewStore(store) { viewStore in
            BoardView()
            	// Trigger rerendering when the GameState is changed
                .id(viewStore.state)
            	// Prepare the game
                .onAppear { viewStore.send(.reset) }
                .gesture(ControlGesture())
            	// Pass the ViewStore so our subviews can interact with it.
                .alert(
                    store.scope(state: \.gameoverAlertState),
                    dismiss: GameAction.actionSheetDismiss
                )
                .environmentObject(viewStore)
                .padding(.horizontal, 20)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.black.ignoresSafeArea())
	}
}

// MARK: SubViews


fileprivate struct BoardView: View {
	// Dependencies
	@EnvironmentObject var viewStore: ViewStore<GameState, GameAction>
	
	var body: some View {
		Canvas { context, size in
			var player = Path()
			
			viewStore
				.player
				.map { coordinate in
					Path(
						size.gridItemFrame(
							row: coordinate.row,
							column: coordinate.column,
							rows: viewStore.rows,
							columns: viewStore.columns
						)
					)
				}
				.forEach { path in
					player.addPath(path)
					player.closeSubpath()
				}
			
			context.fill(player, with: .color(viewStore.gameoverAlertState == nil ? .red : .white))
			context.fill(
				Path(
					size.gridItemFrame(
						row: viewStore.food.row,
						column: viewStore.food.column,
						rows: viewStore.rows,
						columns: viewStore.columns
					)
				),
				with: .color(.yellow)
			)
		}
		.aspectRatio(Double(viewStore.rows) / Double(viewStore.columns), contentMode: .fit)
		.background(Color.blue)
	}
}

// MARK: Gestures

struct ControlGesture: Gesture {
	// Dependencies
	@EnvironmentObject var viewStore: ViewStore<GameState, GameAction>
	
	func handle(value: DragGesture.Value) {
		let vertical = abs(value.translation.width) < abs(value.translation.height)	
                                                        
        if vertical {
            if value.translation.height > 0 {
                viewStore.send(.change(.up))
            } else {
                viewStore.send(.change(.down))
            }
        } else {
            if value.translation.width > 0 {
                viewStore.send(.change(.right))
            } else {
                viewStore.send(.change(.left))
            }
        }
	}
	
	var body: some Gesture {
		DragGesture(minimumDistance: 10, coordinateSpace: .local)
			.onEnded(handle(value:))
	}
}

// MARK: Util

fileprivate extension CGSize {
	func gridItemFrame(row: Int, column: Int, rows: Int, columns: Int) -> CGRect {
		let tileWidth: CGFloat = width / CGFloat(rows)
		let tileHeight: CGFloat = height / CGFloat(columns)
		return CGRect(
			x: CGFloat(row) * tileWidth,
			y: CGFloat(column) * tileHeight,
			width: tileWidth,
			height: tileHeight
		)
	}
}

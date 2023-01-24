import AffirmationsClient
import ComposableArchitecture
import SwiftUI

import ComposableArchitecture
import SwiftUI

public struct App: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        public var affirmation: String = ""
        public var opacity: CGFloat = .zero
    }
    
    // MARK: - Action
    public enum Action {
        case task
        case affirmationLoaded(Affirmation)
        case transition
    }
    
    @Dependency(\.affirmations) var affirmations
    
    // MARK: - Reducer Body
    public var body: some ReducerProtocol<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .task:
                return .task {
                    let affirmation = try await self.affirmations.dailyAffirmation()
                    return .affirmationLoaded(affirmation)
                }
                
            case let .affirmationLoaded(affirmation):
                state.affirmation = affirmation.title
                
                return .run { send in
                    await send(.transition, animation: .easeIn(duration: 1.5))
                }
                
            case .transition:
                state.opacity = 1
                return .none
                
            default:
                return .none
            }
        }
    }
}

// MARK: - View
public struct AppView: View {
    let store: StoreOf<App>
    @ObservedObject var viewStore: ViewStoreOf<App>
    
    public init(
        store: StoreOf<App>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        VStack {
            Text(viewStore.affirmation)
                .foregroundColor(.white)
                .opacity(viewStore.opacity)
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .task {
            viewStore.send(.task)
        }
    }
}

// MARK: - Preview
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: .init(
                initialState: .init(),
                reducer: App()
            )
        )
    }
}

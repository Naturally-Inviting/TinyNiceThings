import AffirmationsClient
import ComposableArchitecture
import ComposableUserNotifications
import NotificationHelpers
import RemoteNotificationsClient
import SwiftUI

public struct AppReducer: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        public var affirmation: String
        public var opacity: CGFloat
        public var appDelegate: AppDelegateReducer.State
        
        public init(
            affirmation: String = "",
            opacity: CGFloat = .zero,
            appDelegate: AppDelegateReducer.State = .init()
        ) {
            self.affirmation = affirmation
            self.opacity = opacity
            self.appDelegate = appDelegate
        }
    }
    
    // MARK: - Action
    public enum Action {
        case task
        case affirmationLoaded(Affirmation)
        case transition
        case appDelegate(AppDelegateReducer.Action)
        case signUpForNotifications
    }
    
    public init() {}
    
    @Dependency(\.affirmations) var affirmations
    @Dependency(\.remoteNotifications) var remoteNotifications
    @Dependency(\.userNotifications) var userNotifications

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
                
            case .signUpForNotifications:
                return .fireAndForget {
                    if try await self.userNotifications.requestAuthorization([.alert, .sound]) {
                        await registerForRemoteNotificationsAsync(
                            remoteNotifications: self.remoteNotifications,
                            userNotifications: self.userNotifications
                        )
                    }
                }
                
            default:
                return .none
            }
        }
        
        Scope(state: \.appDelegate, action: /Action.appDelegate) {
            AppDelegateReducer()
        }
    }
}

// MARK: - View
public struct AppView: View {
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStoreOf<AppReducer>
    
    public init(
        store: StoreOf<AppReducer>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        VStack {
            Text(viewStore.affirmation)
                .foregroundColor(.white)
                .opacity(viewStore.opacity)
            
            Button("Register", action: { viewStore.send(.signUpForNotifications) })
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
                reducer: AppReducer()
            )
        )
    }
}

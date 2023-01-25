import AffirmationsClient
import ComposableArchitecture
import ComposableUserNotifications
import NotificationHelpers
import RemoteNotificationsClient
import SwiftUI

public struct AppReducer: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        public var appDelegate: AppDelegateReducer.State
        public var home: Home.State
        
        public init(
            appDelegate: AppDelegateReducer.State = .init(),
            home: Home.State = .init()
        ) {
            self.appDelegate = appDelegate
            self.home = home
        }
    }
    
    // MARK: - Action
    public enum Action {
        case appDelegate(AppDelegateReducer.Action)
        case home(Home.Action)
        case signUpForNotifications
    }
    
    public init() {}
    
    @Dependency(\.remoteNotifications) var remoteNotifications
    @Dependency(\.userNotifications) var userNotifications

    // MARK: - Reducer Body
    public var body: some ReducerProtocol<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
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
        
        Scope(state: \.home, action: /Action.home) {
            Home()
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
        HomeView(
            store: self.store.scope(
                state: \.home,
                action: AppReducer.Action.home
            )
        )
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

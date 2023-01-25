import ComposableArchitecture
import ComposableUserNotifications
import RemoteNotificationsClient
import UIKit

public struct AppDelegateReducer: ReducerProtocol {
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action: Equatable {
        case didFinishLaunching
        case didRegisterForRemoteNotifications(TaskResult<Data>)
        case userNotifications(UserNotificationClient.DelegateEvent)
    }
    
    @Dependency(\.remoteNotifications.register) var registerForRemoteNotifications
    @Dependency(\.userNotifications) var userNotifications
    
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .didFinishLaunching:
            return .run { send in
                await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        for await event in self.userNotifications.delegate() {
                            await send(.userNotifications(event))
                        }
                    }
                    
                    group.addTask {
                        let settings = await self.userNotifications.getNotificationSettings()
                        
                        switch settings.authorizationStatus {
                        case .authorized:
                            guard
                                try await self.userNotifications.requestAuthorization([.alert, .sound])
                            else { return }
                        case .notDetermined, .provisional:
                            guard try await self.userNotifications.requestAuthorization(.provisional)
                            else { return }
                        default:
                            return
                        }
                        
                        await self.registerForRemoteNotifications()
                    }
                    
                }
            }
            
        case .didRegisterForRemoteNotifications(.failure):
            return .none
            
        case let .didRegisterForRemoteNotifications(.success(tokenData)):
            let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
            return .fireAndForget {
                let settings = await self.userNotifications.getNotificationSettings()
                print(settings.authorizationStatus.rawValue)
                print(token)
            }
            
        case let .userNotifications(.willPresentNotification(_, completionHandler)):
            return .fireAndForget {
                completionHandler(.banner)
            }
            
        case .userNotifications:
            return .none
        }
    }
}


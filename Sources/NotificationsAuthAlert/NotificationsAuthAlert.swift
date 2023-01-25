import ComposableArchitecture
import ComposableUserNotifications
import NotificationHelpers
import RemoteNotificationsClient

public struct NotificationsAuthAlert: ReducerProtocol {
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action: Equatable {
        case closeButtonTapped
        case delegate(DelegateAction)
        case turnOnNotificationsButtonTapped
    }
    
    public enum DelegateAction: Equatable {
        case close
        case didChooseNotificationSettings(UserNotificationClient.Notification.Settings)
    }
    
    @Dependency(\.remoteNotifications) var remoteNotifications
    @Dependency(\.userNotifications) var userNotifications
    
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .closeButtonTapped:
            return .task { .delegate(.close) }.animation()
            
        case .delegate:
            return .none
            
        case .turnOnNotificationsButtonTapped:
            return .run { send in
                if try await self.userNotifications.requestAuthorization([.alert, .sound]) {
                    await registerForRemoteNotificationsAsync(
                        remoteNotifications: self.remoteNotifications,
                        userNotifications: self.userNotifications
                    )
                }
                await send(
                    .delegate(
                        .didChooseNotificationSettings(self.userNotifications.getNotificationSettings())
                    ),
                    animation: .default
                )
            }
        }
    }
}


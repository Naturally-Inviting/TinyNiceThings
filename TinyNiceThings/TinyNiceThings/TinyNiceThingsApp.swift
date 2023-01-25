import AppCore
import ComposableArchitecture
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    #if DEBUG
    static let appReducer = AppReducer()._printChanges()
    #else
    static let appReducer = AppReducer()._printChanges(.actionLabels)
    #endif
    
    let store = Store(
        initialState: AppReducer.State(),
        reducer: appReducer
    )
    
    var viewStore: ViewStore<Void, AppReducer.Action> {
        ViewStore(self.store.stateless)
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        viewStore.send(.appDelegate(.didFinishLaunching))
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        self.viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        self.viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.failure(error))))
    }
}

@main
struct TinyNiceThingsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: self.appDelegate.store)
        }
    }
}

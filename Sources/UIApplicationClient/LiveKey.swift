import Dependencies
import UIKit

@available(iOSApplicationExtension, unavailable)
extension UIApplicationClient: DependencyKey {
    
    public static var liveValue: UIApplicationClient {
        .live
    }
    
    public static let live = Self(
        alternateIconName: { UIApplication.shared.alternateIconName },
        alternateIconNameAsync: { await UIApplication.shared.alternateIconName },
        open: { @MainActor in await UIApplication.shared.open($0, options: $1) },
        canOpen: { @MainActor in UIApplication.shared.canOpenURL($0) },
        openSettingsURLString: { await UIApplication.openSettingsURLString },
        setAlternateIconName: { @MainActor in try await UIApplication.shared.setAlternateIconName($0) },
        setUserInterfaceStyle: { userInterfaceStyle in
            await MainActor.run {
                guard
                    let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene })
                        as? UIWindowScene
                else { return }
                scene.keyWindow?.overrideUserInterfaceStyle = userInterfaceStyle
            }
        },
        supportsAlternateIcons: { UIApplication.shared.supportsAlternateIcons },
        supportsAlternateIconsAsync: { await UIApplication.shared.supportsAlternateIcons }
    )
}

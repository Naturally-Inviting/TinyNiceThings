import Dependencies
import UIKit

@available(iOSApplicationExtension, unavailable)
extension UIPasteboardClient: DependencyKey {
    
    public static var liveValue: UIPasteboardClient {
        .live
    }
    
    public static let live = Self(
        expirationOptionKey: {
            .expirationDate
        },
        setItems: { items, options in
            UIPasteboard.general.setItems(items, options: options)
        }
    )
}

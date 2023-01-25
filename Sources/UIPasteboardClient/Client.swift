import UIKit

public struct UIPasteboardClient {
    public var expirationOptionKey: () -> UIPasteboard.OptionsKey
    public var setItems: ([[String : Any]], [UIPasteboard.OptionsKey: Any]) -> Void
}

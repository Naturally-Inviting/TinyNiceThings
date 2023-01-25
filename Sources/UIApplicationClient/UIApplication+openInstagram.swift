import Dependencies
import Foundation
import UIPasteboardClient

extension UIApplicationClient {
    @discardableResult
    public func shareImageToInstagramStories(_ imageData: Data) async -> Bool {
        @Dependency(\.date) var date
        @Dependency(\.pasteboardClient) var pasteboard
        
        let urlScheme = URL(
            string: "instagram-stories://share"
        )
        
        guard let urlScheme else { return false }
        
        // Expire pasteboard items in 5 minutes
        let pasteboardOptions = [
            pasteboard.expirationOptionKey(): date.now.addingTimeInterval(60 * 5)
        ]
        
        pasteboard.setItems(
            [["com.instagram.sharedSticker.backgroundImage": imageData]],
            pasteboardOptions
        )
        
        return await self.open(urlScheme, [:])
    }
}

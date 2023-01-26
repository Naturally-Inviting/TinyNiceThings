import Dependencies
import Foundation
import UIPasteboardClient

extension UIApplicationClient {
    public static var instagramUrlScheme: URL {
        URL(string: "instagram-stories://share")!
    }
    
    @discardableResult
    public func shareImageToInstagramStories(_ imageData: Data) async -> Bool {
        @Dependency(\.date) var date
        @Dependency(\.pasteboardClient) var pasteboard
        
        // Expire pasteboard items in 5 minutes
        let pasteboardOptions = [
            pasteboard.expirationOptionKey(): date.now.addingTimeInterval(60 * 5)
        ]
        
        pasteboard.setItems(
            [["com.instagram.sharedSticker.backgroundImage": imageData]],
            pasteboardOptions
        )
        
        return await self.open(UIApplicationClient.instagramUrlScheme, [:])
    }
}

import LinkPresentation
import SwiftUI
import UIKit

class ActivityItemSource: NSObject, UIActivityItemSource {
    var title: String
    var text: String
    
    init(title: String, text: String) {
        self.title = title
        self.text = text
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return "👋 Download TinyNiceThings!\n❤️ Receive positive affirmations daily! \nhttps://apps.apple.com/us/app/tinynicethings/id1668019683"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.iconProvider = NSItemProvider(object: UIImage(named: "logo", in: .module, with: nil)!)
        //This is a bit ugly, though I could not find other ways to show text content below title.
        //https://stackoverflow.com/questions/60563773/ios-13-share-sheet-changing-subtitle-item-description
        //You may need to escape some special characters like "/".
        metadata.originalURL = URL(fileURLWithPath: text)
        return metadata
    }
    
}

public struct ActivityView: UIViewControllerRepresentable {
    
    public var activityItems: [Any]
    public var applicationActivities: [UIActivity]? = nil

    public init(activityItems: [Any], applicationActivities: [UIActivity]? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
    }
    
    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityView>
    ) -> UIActivityViewController {
        var items = activityItems
        items.append(ActivityItemSource.init(title: "Tiny Nice Things", text: "Daily affirmations delivered to you."))
        let controller = UIActivityViewController(activityItems: items, applicationActivities: applicationActivities)
        return controller
    }

    public func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {}
}

import Dependencies
import SwiftUI

struct LiveClient: ImageRenderClient {
    public static func render(view: some View, scale: CGFloat) async -> UIImage? {
        let renderer = await ImageRenderer(content: view)

        await MainActor.run {
            renderer.scale = 3
        }
        
        return await renderer.uiImage
    }

    func render<T>(_ view: T, scale: CGFloat) async -> UIImage where T : View {
        await LiveClient.render(view: view, scale: scale) ?? .init()
    }
}

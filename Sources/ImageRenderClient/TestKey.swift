import Dependencies
import Foundation
import SwiftUI
import XCTestDynamicOverlay

struct ImageNoopClient: ImageRenderClient {
    func render<T>(_ view: T, scale: CGFloat) async -> UIImage where T : View {
        return .init()
    }
}

struct ImageTestClient: ImageRenderClient {
    func render<T>(_ view: T, scale: CGFloat) async -> UIImage where T : View {
        unimplemented("\(Self.self).render")
    }
}

public extension DependencyValues {
    var imageRender: ImageRenderClient {
        get { self[ImageRenderKey.self] }
        set { self[ImageRenderKey.self] = newValue }
    }
}

private enum ImageRenderKey: DependencyKey {
    static var liveValue: any ImageRenderClient = LiveClient()
    static var testValue: any ImageRenderClient = ImageTestClient()
    static var previewValue: any ImageRenderClient = ImageNoopClient()
}

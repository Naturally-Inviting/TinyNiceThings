import SwiftUI

public protocol ImageRenderClient {
    func render<T>(_ view: T, scale: CGFloat) async -> UIImage where T: View
}

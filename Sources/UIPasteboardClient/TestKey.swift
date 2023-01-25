import Dependencies
import XCTestDynamicOverlay

extension DependencyValues {
    public var pasteboardClient: UIPasteboardClient {
        get { self[UIPasteboardClient.self] }
        set { self[UIPasteboardClient.self] = newValue }
    }
}

extension UIPasteboardClient: TestDependencyKey {
    public static let previewValue = Self.noop
    
    public static let testValue = Self(
        expirationOptionKey: XCTUnimplemented("\(Self.self).expirationOptionKey"),
        setItems: XCTUnimplemented("\(Self.self).setItems")
    )
}

extension UIPasteboardClient {
    public static let noop = Self(
        expirationOptionKey: { .expirationDate },
        setItems: { _,_ in }
    )
}

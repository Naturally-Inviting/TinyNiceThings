import Dependencies
import Foundation
import XCTestDynamicOverlay

extension DependencyValues {
    public var affirmations: AffirmationsClient {
        get { self[AffirmationsClient.self] }
        set { self[AffirmationsClient.self] = newValue }
    }
}

extension AffirmationsClient: TestDependencyKey {
    public static var testValue: AffirmationsClient {
        Self(
            dailyAffirmation: unimplemented("\(Self.self).dailyAffirmation")
        )
    }
    
    public static var previewValue: AffirmationsClient = Self(
        dailyAffirmation: { .init(title: "I am in control of my own destiny.") }
    )
}

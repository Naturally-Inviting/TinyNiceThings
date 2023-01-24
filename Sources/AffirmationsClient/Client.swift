import Foundation

public struct Affirmation {
    public var title: String
}

public struct AffirmationsClient {
    public var dailyAffirmation: @Sendable () async throws -> Affirmation
    
    public init(
        dailyAffirmation: @escaping @Sendable () async throws -> Affirmation
    ) {
        self.dailyAffirmation = dailyAffirmation
    }
}

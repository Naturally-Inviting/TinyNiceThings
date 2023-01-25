import Dependencies
import Foundation
import Gen

public enum AffirmationClientError: Error {
    case dataNotFound
}

extension AffirmationsClient: DependencyKey {
    public static var liveValue: AffirmationsClient {
        Self(
            dailyAffirmation: {
                guard let json = Bundle.module.url(forResource: "affirmations", withExtension: "json")
                else { throw AffirmationClientError.dataNotFound }
                
                let data = try Data(contentsOf: json)
                let list = (try JSONSerialization.jsonObject(with: data, options: []) as? [String]) ?? []
                
                let affirmations: [Affirmation] = list.compactMap { .init(title: $0) }
                
                let randomGen = Gen.element(of: affirmations)
                
                return randomGen.run() ?? .init(title: "")
            }
        )
    }
}

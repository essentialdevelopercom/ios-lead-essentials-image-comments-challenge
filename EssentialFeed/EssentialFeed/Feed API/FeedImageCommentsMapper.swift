//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

final class FeedImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteImageCommentsItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageCommentsItem] {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        guard response.isInSuccessRange, let root = try? jsonDecoder.decode(Root.self, from: data) else {
            throw RemoteFeedImageCommentsLoader.Error.invalidData
        }

        return root.items
    }
}

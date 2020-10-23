//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageCommentAuthor: Decodable {
    let username: String
}

struct RemoteImageCommentItem: Decodable {
    let id: UUID
    let message: String
    let created_at: Date
    let author: RemoteImageCommentAuthor
}

class ImageCommentsItemsMapper {
    static let statusOk = 200 ... 299
    struct Root: Decodable {
        let items: [RemoteImageCommentItem]
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageCommentItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard statusOk.contains(response.statusCode), let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        return root.items
    }
}

//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

final class FeedItemsMapper {
	private struct Root: Decodable {
		let items: [RemoteFeedItem]
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}
		
		return root.items.toModels()
	}
}

private extension Array where Element == RemoteFeedItem {
	func toModels() -> [FeedImage] {
		return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
	}
}

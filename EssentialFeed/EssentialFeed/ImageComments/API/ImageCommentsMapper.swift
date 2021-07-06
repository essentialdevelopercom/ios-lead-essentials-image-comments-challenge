//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsMapper {
	private struct Root: Decodable {
		private let items: [RemoteFeedItem]

		private struct RemoteFeedItem: Decodable {
			let id: UUID
			let description: String?
			let location: String?
			let image: URL
		}

		var images: [FeedImage] {
			items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
		}
	}

	public enum Error: Swift.Error {
		case invalidData
	}

	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard isOK(response), let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw Error.invalidData
		}

		return root.images
	}

    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        return (200...299).contains(response.statusCode)
    }
}

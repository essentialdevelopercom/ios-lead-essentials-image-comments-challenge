import Foundation

final class ImageCommentsMapper {
	private struct Root: Decodable {
		let items: [RemoteFeedItem]
	}

	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
		guard isOK(response), let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}

		return root.items
	}

	private static func isOK(_ response: HTTPURLResponse) -> Bool {
		return (200...299).contains(response.statusCode)
	}
}

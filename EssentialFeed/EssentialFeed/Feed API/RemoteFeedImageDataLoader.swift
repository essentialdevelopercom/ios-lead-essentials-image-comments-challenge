//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public typealias RemoteFeedImageDataLoader = RemoteTaskLoader<Data>

public extension RemoteFeedImageDataLoader {
	convenience init(client: HTTPClient) {
		self.init(client: client, mapper: FeedImageDataMapper.map)
	}
}

public final class FeedImageDataMapper {

	public enum Error: Swift.Error {
		case invalidData
	}

	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
		guard response.isOK, !data.isEmpty else {
			throw Error.invalidData
		}

		return data
	}
}

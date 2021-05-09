//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public typealias RemoteFeedLaoder = RemoteLoader<[FeedImage]>

public extension RemoteFeedLaoder {
	convenience init(url: URL, client: HTTPClient) {
		self.init(url: url, client: client, mapper: FeedItemsMapper.map)
	}
}

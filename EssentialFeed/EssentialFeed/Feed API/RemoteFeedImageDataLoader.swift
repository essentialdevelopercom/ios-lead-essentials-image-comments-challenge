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

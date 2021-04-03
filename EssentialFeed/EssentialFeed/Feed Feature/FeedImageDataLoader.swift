//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public protocol LoaderTask {
	func cancel()
}

public protocol FeedImageDataLoader {
	typealias Result = Swift.Result<Data, Error>
	
	func load(from url: URL, completion: @escaping (Result) -> Void) -> LoaderTask
}

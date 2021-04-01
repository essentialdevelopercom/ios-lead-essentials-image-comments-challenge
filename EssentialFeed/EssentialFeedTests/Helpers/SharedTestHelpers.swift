//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
@testable import EssentialFeed

func anyNSError() -> NSError {
	return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
	return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
	return Data("any data".utf8)
}

func anyImage() -> FeedImage {
	FeedImage(id: UUID(), description: "a description", location: "bilbao", url: URL(string: "http://any-url.com")!)
}

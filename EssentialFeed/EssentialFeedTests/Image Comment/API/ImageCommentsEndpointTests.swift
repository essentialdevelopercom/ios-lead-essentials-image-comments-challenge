//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsEndpointTests: XCTestCase {
	func test_imageComments_endpointURL() {
		let baseURL = URL(string: "http://base-url.com")!

		let image = FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
		let received = ImageCommentsEndpoint.get(image).url(baseURL: baseURL)
		let expected = URL(string: "http://base-url.com/v1/image/\(image.id)/comments")!

		XCTAssertEqual(received, expected)
	}
}

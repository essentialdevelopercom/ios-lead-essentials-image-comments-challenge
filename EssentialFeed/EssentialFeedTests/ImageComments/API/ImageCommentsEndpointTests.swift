//
// Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsEndpointTests: XCTestCase {
	func test_imageCommentsEndpoint_endpointURL() {
		let baseURL = URL(string: "http://base-url.com")!

		let sampleCommentsIds = ["1", "50", "200"]

		sampleCommentsIds.forEach { imageId in
			let received = ImageCommentsEndpoint.get.url(baseURL: baseURL, imageId: imageId)
			let expected = URL(string: "http://base-url.com/v1/image/\(imageId)/comments")!

			XCTAssertEqual(received, expected)
		}
	}
}

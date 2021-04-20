//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsEndpointTests: XCTestCase {
	func test_imageComments_endpointURL() {
		let baseURL = URL(string: "http://base-url.com")!
		let imageID = UUID()

		let received = ImageCommentsEndpoint.get.url(baseURL: baseURL, imageID: imageID)
		let expected = URL(string: "http://base-url.com/v1/image/\(imageID)/comments")

		XCTAssertEqual(received, expected)
	}
}

//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsEndpointTests: XCTestCase {
	func test_imageComments_endpintURL() {
		let baseURL = URL(string: "http://base-url.com")!
		let imageID = "an-image-id"
		let expected = URL(string: "http://base-url.com/v1/image/an-image-id/comments")!

		let received = ImageCommentsEndpoint.get(imageID: imageID).url(baseURL: baseURL)

		XCTAssertEqual(received, expected)
	}
}

//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsEndpointTests: XCTestCase {
	func test_imageComments_endpintURL() {
		let baseURL = URL(string: "http://base-url.com")!
		let imageID = UUID(uuidString: "087A31AF-87B9-4019-B708-DEA727E211F9")!
		let expected = URL(string: "http://base-url.com/v1/image/087A31AF-87B9-4019-B708-DEA727E211F9/comments")!

		let received = ImageCommentsEndpoint.get(imageID: imageID).url(baseURL: baseURL)

		XCTAssertEqual(received, expected)
	}
}

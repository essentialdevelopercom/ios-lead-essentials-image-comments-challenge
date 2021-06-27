//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsEndpointTests: XCTestCase {
	func test_imageComments_endpointURL() {
		let baseURL = URL(string: "http://base-url.com")!
		let id = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!

		let received = ImageCommentsEndpoint.get(id).url(baseURL: baseURL)
		let expected = URL(string: "http://base-url.com/v1/image/E621E1F8-C36C-495A-93FC-0C247A3E6E5F/comments")!

		XCTAssertEqual(received, expected)
	}
}

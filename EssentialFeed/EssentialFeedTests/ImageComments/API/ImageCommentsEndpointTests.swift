
import XCTest
import EssentialFeed

class ImageCommentsEndpointTests: XCTestCase {
	func test_getURL() {
		let baseURL = URL(string: "http://any-url.com")!
		let id = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!

		let receivedURL = ImageCommentsEndpoint.get(id).url(baseURL: baseURL)
		let expectedURL = URL(string: "http://any-url.com/v1/image/\(id)/comments")

		XCTAssertEqual(receivedURL, expectedURL)
	}
}

import XCTest
import EssentialFeed

class ImageCommentEndpointTests: XCTestCase {
	func test_imageComments_endpointURL() {
		let baseURL = URL(string: "http://base-url.com")!
		let image = FeedImage(id: UUID(), description: "a description", location: "a location", url: anyURL())
		let received = ImageCommentsEndpoint.get(image).url(baseURL: baseURL)
		let expected = URL(string: "http://base-url.com/v1/image/\(image.id)/comments")!

		XCTAssertEqual(received, expected)
	}
}

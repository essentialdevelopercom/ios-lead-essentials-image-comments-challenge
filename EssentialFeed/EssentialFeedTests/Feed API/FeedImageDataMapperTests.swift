//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedImageDataMapperTests: XCTestCase {
	
	func test_map_throwsInvalidDataErrorOnNon200HTTPResponse() throws {
		let samples = [199, 201, 300, 400, 500]

		try samples.enumerated().forEach { index, code in
			XCTAssertThrowsError(try FeedImageDataMapper.map(anyData(), from: HTTPURLResponse(code: code)))
		}
	}
	
	func test_map_throwsInvalidDataErrorOn200HTTPResponseWithEmptyData() {
		let emptyData = Data()

		XCTAssertThrowsError(try FeedImageDataMapper.map(emptyData, from: HTTPURLResponse(code: 200)))
	}
	
	func test_map_deliversReceivedNonEmptyDataOn200HTTPResponse() throws {
		let nonEmptyData = Data("non-empty data".utf8)

		let result = try FeedImageDataMapper.map(nonEmptyData, from: HTTPURLResponse(code: 200))

		XCTAssertEqual(result, nonEmptyData)
	}
	
}

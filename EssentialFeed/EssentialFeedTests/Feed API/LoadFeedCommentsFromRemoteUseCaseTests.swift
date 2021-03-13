//
//  Created by Azamat Valitov on 13.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedCommentsLoader {
	private let client: HTTPClient
	init(client: HTTPClient) {
		self.client = client
	}
	
	func load(url: URL) {
		client.get(from: url, completion: { _ in })
	}
}

class LoadFeedCommentsFromRemoteUseCaseTests: XCTestCase {
	
	func test_init_doesNotRequestData() {
		let client = HTTPClientSpy()
		let _ = RemoteFeedCommentsLoader(client: client)
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let client = HTTPClientSpy()
		let sut = RemoteFeedCommentsLoader(client: client)
		
		sut.load(url: url)
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
}

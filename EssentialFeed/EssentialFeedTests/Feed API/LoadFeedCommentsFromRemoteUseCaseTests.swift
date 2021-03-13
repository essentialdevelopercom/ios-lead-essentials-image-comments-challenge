//
//  Created by Azamat Valitov on 13.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedCommentsLoader {
	init(client: HTTPClient) {
		
	}
}

class LoadFeedCommentsFromRemoteUseCaseTests: XCTestCase {
	
	func test_init_doesNotRequestData() {
		let client = HTTPClientSpy()
		let _ = RemoteFeedCommentsLoader(client: client)
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
}

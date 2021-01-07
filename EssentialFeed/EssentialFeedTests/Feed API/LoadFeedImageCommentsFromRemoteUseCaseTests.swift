//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class RemoteImageCommentsLoader {
    init(client: HTTPClient) {
        
    }
}

class LoadFeedImageCommentsFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotRequestFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteImageCommentsLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
}

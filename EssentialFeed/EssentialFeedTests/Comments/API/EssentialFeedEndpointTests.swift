//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import XCTest

final class EssentialFeedEndpointTests: XCTestCase {
    func test_feedEndpoint_isCorrectURL() {
        let baseUrl = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
        let endpoint = EssentialFeedEndpoint.feed.url(baseUrl)

        let expected = URL(
            string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed"
        )!
        XCTAssertEqual(endpoint, expected, "Expected \(expected.absoluteString) URL, but got \(endpoint.absoluteString) instead")
    }

    func test_imageCommentsEndpont_isCorrectURL() {
        let baseUrl = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
        let imageId = "5bcc6f46-1a48-11eb-adc1-0242ac120002"
        let endpoint = EssentialFeedEndpoint.comments(for: imageId).url(baseUrl)

        let expected =
            URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/5bcc6f46-1a48-11eb-adc1-0242ac120002/comments")!
        XCTAssertEqual(endpoint, expected, "Expected \(expected.absoluteString) URL, but got \(endpoint.absoluteString) instead")
    }
}

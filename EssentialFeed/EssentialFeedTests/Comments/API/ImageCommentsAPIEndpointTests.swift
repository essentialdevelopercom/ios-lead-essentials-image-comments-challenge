//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

enum ImageCommentsEndpoint {
    typealias ImageUUID = String

    case comments(for: ImageUUID)

    func url() -> URL {
        switch self {
        case let .comments(uuid):
            return URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(uuid)/comments")!
        }
    }
}

final class ImageCommentsAPIEndpointTests: XCTestCase {
    func test_imageCommentsEndpont_isCorrectURL() {
        let imageId = "5bcc6f46-1a48-11eb-adc1-0242ac120002"
        let endpoint = ImageCommentsEndpoint.comments(for: imageId).url()

        let expected =
            URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/5bcc6f46-1a48-11eb-adc1-0242ac120002/comments")!
        XCTAssertEqual(endpoint, expected, "Expected \(expected.absoluteString) URL, but got \(endpoint.absoluteString) instead")
    }
}

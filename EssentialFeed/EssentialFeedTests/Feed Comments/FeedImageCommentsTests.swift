//
//  FeedImageCommentsTests.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct FeedComment {
	let id: UUID
	let message: String
	let createdAt: String
	let author: FeedCommentAuthor
}

struct FeedCommentAuthor {
	let username: String
}

class RemoteImageFeedCommentLoader {
	
	private let client: HTTPClient
	
	init(client: HTTPClient) {
		self.client = client
	}
	
	func load(imageId: String, completion: @escaping (Result<[FeedComment], Error>) -> Void) {
		
	}
	
}

final class FeedImageCommentsTests: XCTestCase {

	func test_init_doesNotRequestDataFromUrl() {
		let client = HTTPClientSpy()
		let loader = RemoteImageFeedCommentLoader(client: client)
		
		loader.load(imageId: "any", completion: { _ in })
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	
}

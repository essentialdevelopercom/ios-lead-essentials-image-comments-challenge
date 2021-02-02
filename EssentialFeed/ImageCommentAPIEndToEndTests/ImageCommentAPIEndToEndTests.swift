//
//  ImageCommentAPIEndToEndTests.swift
//  ImageCommentAPIEndToEndTests
//
//  Created by Alok Subedi on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentAPIEndToEndTests: XCTestCase {
	
	func test_endToEndServerGETImageCommentResult_matchesServerData() {
		let imageId = "31768993-1A2E-4B65-BD2A-D8AF06416730"
		
		let serverUrl = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(imageId)/comments")!
		let serverClient = URLSessionHTTPClient(session: .shared)
		let loader = RemoteImageCommentsLoader(client: serverClient, url: serverUrl)
		
		let exp = expectation(description: "Wait for load to complete")
		
		loader.load { result in
			switch result {
			case let .success(recievedComments):
				XCTAssertEqual(recievedComments.count, 3, "Expected 3 images in the test account image feed")
			case let .failure(error):
				XCTFail("Expected successful Image Comments, got \(error) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 5.0)
	}
}

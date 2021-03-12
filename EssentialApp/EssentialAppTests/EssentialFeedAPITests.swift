//
//  EssentialFeedAPITests.swift
//  EssentialAppTests
//
//  Created by Lukas Bahrle Santana on 12/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialApp

class EssentialFeedAPITests: XCTestCase {

	func test_feedEndpoint_isCorrect(){
		let baseURL = URL(string: "https://base-url.com")!
		let sut = EssentialFeedAPI(baseURL: baseURL)
		
		let expectedURL = URL(string: "https://base-url.com/v1/feed")!

		XCTAssertEqual(sut.url(for: .feed) , expectedURL)
	}
	
	func test_commentsEndpoint_isCorrect(){
		let baseURL = URL(string: "https://base-url.com")!
		let commentId = UUID(uuidString: "CE86A1DE-11C8-407B-B1C7-39B8BFA124F1")!
		let sut = EssentialFeedAPI(baseURL: baseURL)
		
		let expectedURL = URL(string: "https://base-url.com/v1/image/CE86A1DE-11C8-407B-B1C7-39B8BFA124F1/comments")!

		XCTAssertEqual(sut.url(for: .imageComments(id: commentId)), expectedURL)
	}

}

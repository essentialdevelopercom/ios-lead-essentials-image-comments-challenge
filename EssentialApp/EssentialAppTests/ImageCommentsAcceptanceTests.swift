//
//  ImageCommentsAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Adrian Szymanowski on 17/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class ImageCommentsAcceptanceTests: XCTestCase {
	
	func test_onAppear_displaysRemoteImageCommentsWhenCustomerHasConnectivity() {
		let comments = launch(httpClient: .online(response))
		
		XCTAssertEqual(comments.numberOfRenderedImageCommentsViews(), 2)
	}
	
	func test_onAppear_displaysNoCommentsWhenCustomerHasNoConnectivity() {
		let comments = launch(httpClient: .offline)
		
		XCTAssertEqual(comments.numberOfRenderedImageCommentsViews(), 0)
	}
	
	// MARK: - Helpers
	
	private func launch(httpClient: HTTPClientStub = .offline) -> ImageCommentsViewController {
		let store = InMemoryFeedStore.empty
		let sut = SceneDelegate(httpClient: httpClient, store: store)
		sut.window = UIWindow()
		sut.configureWindow()
		sut.navigateToComment(makeFeedImage)
		RunLoop.main.run(until: Date())
		
		let nav = sut.window?.rootViewController as? UINavigationController
		return nav?.topViewController as! ImageCommentsViewController
	}
	
	private func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeData(for: url), response)
	}
	
	private func makeData(for url: URL) -> Data {
		makeImageCommentsData()
	}
	
	private var makeFeedImage: FeedImage {
		FeedImage(
			id: UUID(),
			description: "test description",
			location: "some location",
			url: anyURL())
	}
	
	private func makeImageCommentsData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": "d7e5515d-8dd4-441f-9872-530768d9f3e9", "message": "test message", "created_at" : "2014-12-24T00:00:00+00:00", "author": ["username": "test user"]],
			["id": "1fb87ef8-c25b-42b8-8ff1-ffc6b32b1687", "message": "test message 2", "created_at" : "2021-01-02T12:13:14+00:00", "author": ["username": "test user 2"]]
		]])
	}
	
}

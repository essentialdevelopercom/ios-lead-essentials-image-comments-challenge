//
//  FeedImageCommentsAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Ivan Ornes on 7/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedImageCommentsAcceptanceTests: XCTestCase {
	
	func test_onImageSelection_displaysFirstFeedImageCommets() {
		let feed = launch(httpClient: .online(response), store: .empty)
		
		feed.simulateFeedImageViewTap(at: 0)
		RunLoop.current.run(until: Date())
		
		let commentsVC = feed.navigationController!.topViewController! as! FeedImageCommentsViewController
		
		XCTAssertEqual(commentsVC.numberOfRenderedFeedImageCommentViews(), 2, "Render two comments")
		XCTAssertNil(commentsVC.errorMessage, "No display an error message")
		
		let comment1 = commentsVC.feedImageCommentView(at: 0)
		let comment2 = commentsVC.feedImageCommentView(at: 1)
		
		XCTAssertEqual(comment1?.messageText, "a message", "First comment message")
		XCTAssertEqual(comment2?.messageText, "another message", "Second comment message")
		
		XCTAssertEqual(comment1?.authorText, "a username", "First comment author")
		XCTAssertEqual(comment2?.authorText, "another username", "First comment author")
	}
	
	// MARK: - Helpers
	
	private func launch(
		httpClient: HTTPClientStub = .offline,
		store: InMemoryFeedStore = .empty
	) -> FeedViewController {
		let sut = SceneDelegate(httpClient: httpClient, store: store)
		sut.window = UIWindow()
		sut.configureWindow()
		
		let nav = sut.window?.rootViewController as? UINavigationController
		return nav?.topViewController as! FeedViewController
	}
	
	private func enterBackground(with store: InMemoryFeedStore) {
		let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
		sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
	}
	
	private func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeData(for: url), response)
	}
	
	private func makeData(for url: URL) -> Data {
		switch url.absoluteString {
		case "http://image.com":
			return makeImageData()
		case  "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed":
			return makeFeedData()
		case  "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/11E123D5-1272-4F17-9B91-F3D0FFEC895A/comments":
			return makeCommentsData()
		default:
			return makeFeedData()
		}
	}
	
	private func makeImageData() -> Data {
		return UIImage.make(withColor: .red).pngData()!
	}
	
	private func makeFeedData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": "11E123D5-1272-4F17-9B91-F3D0FFEC895A", "image": "http://image.com"],
			["id": "31768993-1A2E-4B65-BD2A-D8AF06416730", "image": "http://image.com"]
		]])
	}
	
	private func makeCommentsData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			[
				"id": "11E123D5-1272-4F17-9B91-F3D0FFEC895A",
				"message": "a message",
				"created_at": "2020-08-28T15:07:02+00:00",
				"author": [
					"username": "a username"
				]
			],
			[
				"id": "31768993-1A2E-4B65-BD2A-D8AF06416730",
				"message": "another message",
				"created_at": "2020-01-01T12:31:22+00:00",
				"author": [
					"username": "another username"
				]
			]
		]])
	}
}

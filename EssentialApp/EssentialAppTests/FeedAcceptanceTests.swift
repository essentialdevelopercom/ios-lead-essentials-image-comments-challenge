//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedAcceptanceTests: XCTestCase {
	
	func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
		let feed = launch(httpClient: .online(response), store: .empty)
		
		XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
		XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
		XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
	}
	
	func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
		let sharedStore = InMemoryFeedStore.empty
		let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
		onlineFeed.simulateFeedImageViewVisible(at: 0)
		onlineFeed.simulateFeedImageViewVisible(at: 1)
		
		let offlineFeed = launch(httpClient: .offline, store: sharedStore)
		
		XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData0())
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData1())
	}
	
	func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
		let feed = launch(httpClient: .offline, store: .empty)
		
		XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
	}
	
	func test_onEnteringBackground_deletesExpiredFeedCache() {
		let store = InMemoryFeedStore.withExpiredFeedCache
		
		enterBackground(with: store)
		
		XCTAssertNil(store.feedCache, "Expected to delete expired cache")
	}
	
	func test_onEnteringBackground_keepsNonExpiredFeedCache() {
		let store = InMemoryFeedStore.withNonExpiredFeedCache
		
		enterBackground(with: store)
		
		XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
	}

	func test_onFeedImageSelecton_displaysComments() {
		let comments = showCommentsForFirstImage()

		XCTAssertEqual(comments.numberOfRenderedComments(), 1)
		XCTAssertEqual(comments.commentCell(at: 0)?.message, makeCommentMessage())
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
		let response = HTTPURLResponse(
			url: url,
			statusCode: 200,
			httpVersion: nil,
			headerFields: nil
		)!
		return (makeData(for: url), response)
	}

	private func showCommentsForFirstImage() -> ImageCommentsViewController {
		let feed = launch(httpClient: .online(response), store: .empty)

		feed.simulateTapOnFeedImage(at: 0)
		RunLoop.current.run(until: Date())

		let navigationController = feed.navigationController
		return navigationController?.topViewController as! ImageCommentsViewController
	}

	
	private func makeData(for url: URL) -> Data {
		switch url.path {
		case "/image-0":
			return makeImageData0()

		case "/image-1":
			return makeImageData1()

		case "/essential-feed/v1/image/\(makeFirstImageID())/comments":
			return makeCommentsData()
			
		default:
			return makeFeedData()
		}
	}

	private func makeImageData0() -> Data {
		UIImage.make(withColor: .red).pngData()!
	}

	private func makeImageData1() -> Data {
		UIImage.make(withColor: .green).pngData()!
	}

	private func makeFirstImageID() -> String {
		"2AB2AE66-A4B7-4A16-B374-51BBAC8DB086"
	}
	
	private func makeFeedData() -> Data {
		try! JSONSerialization.data(withJSONObject: ["items": [
			["id": makeFirstImageID(), "image": "http://feed.com/image-0"],
			["id": "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A", "image": "http://feed.com/image-1"]
		]])
	}

	private func makeCommentsData() -> Data {
		try! JSONSerialization.data(
			withJSONObject: ["items": [[
				"id": UUID().uuidString,
				"message": makeCommentMessage(),
				"created_at": "2021-02-20T17:20:00+0000",
				"author": [
					"username": "a username"
				]
			]]]
		)
	}

	private func makeCommentMessage() -> String {
		"a message"
	}
}

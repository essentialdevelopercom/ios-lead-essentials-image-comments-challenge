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
		XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
	}
	
	func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
		let sharedStore = InMemoryFeedStore.empty
		let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
		onlineFeed.simulateFeedImageViewVisible(at: 0)
		onlineFeed.simulateFeedImageViewVisible(at: 1)
		
		let offlineFeed = launch(httpClient: .offline, store: sharedStore)
		
		XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
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
	
	func test_onFeedImageCellSelect_navigatesToImageCommentsView() {
		let feed = launch(httpClient: .online(response), store: .empty)
		
		feed.simulateFeedImageSelection(at: 0)
		RunLoop.current.run(until: Date())
		
		let comments = feed.navigationController?.topViewController as! ImageCommentsViewController
		XCTAssertEqual(comments.numberOfRenderedImageCommentViews(), 1)
		XCTAssertEqual(comments.imageCommentMessage(at: 0), makeCommentMessage())
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
		switch url.path {
		case "/image-1", "/image-2":
			return makeImageData()
			
		case "/essential-feed/v1/feed":
			return makeFeedData()
		
		case "/essential-feed/v1/image/E1EE6B46-55D7-4978-AE0D-FD4D40749827/comments":
			return makeCommentsData()
			
		default:
			return Data()
		}
	}
	
	private func makeImageData() -> Data {
		return UIImage.make(withColor: .red).pngData()!
	}
	
	private func makeFeedData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": "E1EE6B46-55D7-4978-AE0D-FD4D40749827", "image": "http://image.com/image-1"],
			["id": "AC3EA268-E6F3-46BA-AE2F-B129E8BAA7B5", "image": "http://image.com/image-2"]
		]])
	}
	
	private func makeCommentMessage() -> String {
		return "a comment"
	}
	
	private func makeCommentsData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			[
				"id": UUID().uuidString,
				"message": makeCommentMessage(),
				"created_at": "2020-05-20T11:24:59+0000",
				"author": [
				  "username": "a username"
				]
			],
		]])
	}
	
}

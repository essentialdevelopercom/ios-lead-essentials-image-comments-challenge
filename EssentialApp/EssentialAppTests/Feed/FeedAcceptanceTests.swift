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

	func test_feedImageSelection_navigatesToImageComments() {
		let feed = launch(httpClient: .online(response), store: .empty)

		feed.simulateFeedImageSelection(at: 0)
		RunLoop.current.run(until: Date())

		let comments = feed.navigationController?.topViewController as? ImageCommentsViewController
		XCTAssertNotNil(comments, "Expected shown view to be the image comments UI")
		XCTAssertEqual(comments?.numberOfRenderedCommentViews(), 2)

		XCTAssertNotNil(comments?.commentView(at: 0), "Expected a comment view for the first comment")
		XCTAssertEqual(comments?.commentMessage(at: 0), "some message")

		XCTAssertNotNil(comments?.commentView(at: 1), "Expected a comment view for the second comment")
		XCTAssertEqual(comments?.commentMessage(at: 1), "another message")
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

		case "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed":
			return makeFeedData()

		case "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/2C6A70A3-FA35-449C-816F-6C6F7C294393/comments":
			return makeCommentsData()

		default:
			fatalError("There's no data defined for \(url)")
		}
	}
	
	private func makeImageData() -> Data {
		return UIImage.make(withColor: .red).pngData()!
	}
	
	private func makeFeedData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": "2c6a70a3-fa35-449c-816f-6c6f7c294393", "image": "http://image.com"],
			["id": UUID().uuidString, "image": "http://image.com"]
		]])
	}

	private func makeCommentsData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": UUID().uuidString, "message": "some message", "created_at" : "2008-09-24T02:10:22+00:00", "author": ["username": "some user"]],
			["id": UUID().uuidString, "message": "another message", "created_at" : "2012-04-02T02:22:13+00:00", "author": ["username": "another user"]]
		]])
	}
}

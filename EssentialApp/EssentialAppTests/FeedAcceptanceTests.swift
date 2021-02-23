//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedAcceptanceTests: XCTestCase {
	
	func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
		let (_, feed) = launch(httpClient: .online(response), store: .empty)
		
		XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
		XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
	}
	
	func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
		let sharedStore = InMemoryFeedStore.empty
		let (_, onlineFeed) = launch(httpClient: .online(response), store: sharedStore)
		onlineFeed.simulateFeedImageViewVisible(at: 0)
		onlineFeed.simulateFeedImageViewVisible(at: 1)
		
		let (_, offlineFeed) = launch(httpClient: .offline, store: sharedStore)
		
		XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
	}
	
	func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
		let (_, feed) = launch(httpClient: .offline, store: .empty)
		
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
	
	func test_onFeedImageTap_displaysFeedImageComments() throws {
		let (sut, feed) = launch(httpClient: .online(response), store: .empty)
		
		feed.simulateFeedImageTap(at: 0)
		
		executeRunLoop()
		
		let feedCommentsController = try XCTUnwrap(topController(for: sut.window) as? FeedImageCommentViewController, "Expected a feed image comment controller as top view controller, got \(String(describing: topController)) instead")
		
		feedCommentsController.loadViewIfNeeded()
		
		XCTAssertEqual(feedCommentsController.numberOfRenderedFeedImageCommentsViews(), 3)
	}
		
	// MARK: - Helpers
	
	private func makeSUT(httpClient: HTTPClientStub,
						 store: InMemoryFeedStore, 
						 file: StaticString = #file, line: UInt = #line) -> SceneDelegate {
		let sut = SceneDelegate(httpClient: httpClient, store: store)
		sut.window = UIWindow()
		sut.configureWindow()
		return sut
	}
	
	private func launch(
		httpClient: HTTPClientStub = .offline,
		store: InMemoryFeedStore = .empty
	) -> (sut: SceneDelegate, feed: FeedViewController) {
		let sut = makeSUT(httpClient: httpClient, store: store)
		let nav = sut.window?.rootViewController as? UINavigationController
		return (sut, nav?.topViewController as! FeedViewController)
	}
	
	private func enterBackground(with store: InMemoryFeedStore) {
		let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
		sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
	}
	
	private func topController(for window: UIWindow?) -> UIViewController? {
		let root = window?.rootViewController
		let rootNavigation = root as? UINavigationController
		return rootNavigation?.topViewController
	}
	
	private func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeData(for: url), response)
	}
	
	private func makeData(for url: URL) -> Data {
		switch url.pathComponents.last {
		case "comments":
			return makeFeedCommentData()
			
		case "feed":
			return makeFeedData()
			
		default:
			return makeImageData()
		}
	}
	
	private func makeImageData() -> Data {
		return UIImage.make(withColor: .red).pngData()!
	}
	
	private func makeFeedData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": UUID().uuidString, "image": "http://image.com"],
			["id": UUID().uuidString, "image": "http://image.com"]
		]])
	}
	
	private func responseForFeedComments(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeFeedCommentData(), response)
	}
	
	private func makeFeedCommentData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			[
				"id": UUID().uuidString, 
				"message": "a messege", 
				"created_at": "2020-05-20T11:24:59+0000",
				"author": ["username": "An Author"]
			],
			[
				"id": UUID().uuidString, 
				"message": "a messege", 
				"created_at": "2020-05-20T11:24:59+0000",
				"author": ["username": "An Author"]
			],
			[
				"id": UUID().uuidString, 
				"message": "a messege", 
				"created_at": "2020-05-20T11:24:59+0000",
				"author": ["username": "An Author"]
			]
		]])
	}
	
	private func executeRunLoop() {
		RunLoop.current.run(until: Date())
	}
}

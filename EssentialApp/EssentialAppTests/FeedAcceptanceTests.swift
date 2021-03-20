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
	
	func test_onFeedImageSelection_opensCommentsScreenForSelectedFeedImage() throws {
		let uuid0 = UUID()
		let uuid1 = UUID()
		let (navigationController, feed) = launch(httpClient: .online({url in
			self.makeFeedDataWithConcreteUUIDs(uuids: [uuid0, uuid1], udidToBeSelected: uuid1, for: url)
		}, make200Response), store: .empty)
		
		feed.simulateFeedCommentDidSelect(at: 1)
		
		let commentsViewController = try XCTUnwrap(navigationController.topViewController as? FeedCommentsViewController)
		XCTAssertNotNil(commentsViewController)
		
		commentsViewController.view.layoutIfNeeded()
		XCTAssertEqual(commentsViewController.numberOfRenderedFeedCommentViews(), 2)
	}
	
	// MARK: - Helpers
	
	private func launch(
		httpClient: HTTPClientStub = .offline,
		store: InMemoryFeedStore = .empty
	) -> (navigationController: UINavigationController, feedViewController: FeedViewController) {
		let sut = SceneDelegate(httpClient: httpClient, store: store)
		sut.window = UIWindow()
		sut.configureWindow()
		
		let nav = sut.window?.rootViewController as! UINavigationController
		return (nav, nav.topViewController as! FeedViewController)
	}
	
	private func enterBackground(with store: InMemoryFeedStore) {
		let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
		sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
	}
	
	private func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = make200Response(for: url)
		return (makeData(for: url), response)
	}
	
	private func make200Response(for url: URL) -> HTTPURLResponse {
		HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
	}
	
	private func makeData(for url: URL) -> Data {
		switch url.absoluteString {
		case "http://image.com":
			return makeImageData()
			
		default:
			return makeFeedData()
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
	
	private func makeFeedDataWithConcreteUUIDs(uuids: [UUID], udidToBeSelected: UUID, for url: URL) -> Data {
		if url.absoluteString.contains(udidToBeSelected.uuidString) {
			return try! JSONSerialization.data(withJSONObject: ["items": [
				["id": UUID().uuidString, "message": "a message",
				 "created_at": "2020-05-20T11:24:59+0000", "author": [
					"username": "a username"
				 ]],
				["id": UUID().uuidString, "message": "another message",
				 "created_at": "2020-05-19T14:23:53+0000", "author": [
					"username": "another username"
				 ]]
			]])
		} else {
			return try! JSONSerialization.data(withJSONObject: ["items": uuids.map({["id": $0.uuidString, "image": "http://image.com"]})])
		}
	}
}

extension FeedViewController {
	func simulateFeedCommentDidSelect(at index: Int) {
		tableView(tableView, didSelectRowAt: IndexPath(row: index, section: feedImagesSection))
		RunLoop.current.run(until: Date())
	}
	
	private var feedImagesSection: Int {
		return 0
	}
}

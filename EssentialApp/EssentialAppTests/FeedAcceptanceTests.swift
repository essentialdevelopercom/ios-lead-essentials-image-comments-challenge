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
	
	func test_onFeedImageSelection_opensCommentsScreenForSelectedFeedImage() throws {
		let uuid0 = UUID()
		let uuid1 = UUID()
		let comment0 = (message: "any message", authorName: "any author name")
		let comment1 = (message: "another message", authorName: "another author name")
		let (navigationController, feed) = launchAndReturnWithNavigationController(httpClient: .online({url in
			self.makeFeedDataWithConcreteUUIDs(uuids: [uuid0, uuid1], comments: [
				comment0,
				comment1
			], udidToBeSelected: uuid1, for: url)
		}, make200Response), store: .empty)
		
		feed.simulateFeedCommentDidSelect(at: 1)
		
		let commentsViewController = try XCTUnwrap(navigationController.topViewController as? FeedCommentsViewController)
		XCTAssertNotNil(commentsViewController)
		
		commentsViewController.view.layoutIfNeeded()
		XCTAssertEqual(commentsViewController.numberOfRenderedFeedCommentViews(), 2)
		
		let cell0 = commentsViewController.simulateFeedImageViewVisible(at: 0)
		XCTAssertEqual(cell0?.message, comment0.message)
		XCTAssertEqual(cell0?.authorName, comment0.authorName)
		
		let cell1 = commentsViewController.simulateFeedImageViewVisible(at: 1)
		XCTAssertEqual(cell1?.message, comment1.message)
		XCTAssertEqual(cell1?.authorName, comment1.authorName)
	}
	
	// MARK: - Helpers
	
	private func launch(
			httpClient: HTTPClientStub = .offline,
			store: InMemoryFeedStore = .empty
	) -> FeedViewController {
		return launchAndReturnWithNavigationController(httpClient: httpClient, store: store).feedViewController
	}
	
	private func launchAndReturnWithNavigationController(
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
	
	private func makeFeedDataWithConcreteUUIDs(uuids: [UUID], comments: [(message: String, authorName: String)] ,udidToBeSelected: UUID, for url: URL) -> Data {
		if url.absoluteString.contains(udidToBeSelected.uuidString) {
			return try! JSONSerialization.data(withJSONObject: ["items":
				comments.map({ comment in
					["id": UUID().uuidString, "message": comment.message,
					 "created_at": "2020-05-20T11:24:59+0000", "author": [
						"username": comment.authorName
					 ]]
				})
			])
		} else {
			return try! JSONSerialization.data(withJSONObject: ["items": uuids.map({["id": $0.uuidString, "image": "http://image.com"]})])
		}
	}
}

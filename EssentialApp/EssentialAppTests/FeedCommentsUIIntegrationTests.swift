//
//  Created by Azamat Valitov on 14.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedCommentsViewController: UITableViewController {
	
	private var loader: FeedCommentsLoader!
	convenience init(loader: FeedCommentsLoader) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = feedCommentsTitle
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
		loader.load(url: URL(string: "http://any-url.com")!, completion: { _ in })
	}
	
	@objc private func refresh() {
		loader.load(url: URL(string: "http://any-url.com")!, completion: { _ in })
	}
	
	private var feedCommentsTitle: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_TITLE",
			 tableName: "FeedComments",
			 bundle: Bundle(for: FeedCommentsViewController.self),
			 comment: "Title for feed comments view")
	}
}

class FeedCommentsUIIntegrationTests: XCTestCase {
	
	func test_feedCommentsView_hasTitle() {
		let loader = LoaderSpy()
		let sut = FeedCommentsViewController(loader: loader)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("FEED_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadFeedCommentsActions_requestCommentsFromLoader() {
		let loader = LoaderSpy()
		let sut = FeedCommentsViewController(loader: loader)
		XCTAssertEqual(loader.loadFeedCommentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadFeedCommentsCallCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedFeedCommentsReload()
		XCTAssertEqual(loader.loadFeedCommentsCallCount, 2, "Expected another loading request once user initiates a reload")
		
		sut.simulateUserInitiatedFeedCommentsReload()
		XCTAssertEqual(loader.loadFeedCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}
	
	// MARK: - Helpers
	
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "FeedComments"
		let bundle = Bundle(for: FeedCommentsViewController.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	class LoaderSpy: FeedCommentsLoader {
		var loadFeedCommentsCallCount = 0
		func load(url: URL, completion: @escaping (FeedCommentsLoader.Result) -> Void) {
			loadFeedCommentsCallCount += 1
		}
	}
}

extension FeedCommentsViewController {
	func simulateUserInitiatedFeedCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
}

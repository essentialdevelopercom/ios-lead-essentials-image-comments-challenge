//
//  Created by Azamat Valitov on 14.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedCommentsViewController: UITableViewController {
	
	private var url: URL!
	private var loader: FeedCommentsLoader!
	convenience init(url: URL, loader: FeedCommentsLoader) {
		self.init()
		self.url = url
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = feedCommentsTitle
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
		loader.load(url: url, completion: { _ in })
	}
	
	@objc private func refresh() {
		loader.load(url: url, completion: { _ in })
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
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("FEED_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadFeedCommentsActions_requestCommentsFromLoader() {
		let url = URL(string: "https://comments-url.com")!
		let (sut, loader) = makeSUT(url: url)
		XCTAssertEqual(loader.loadedUrls, [], "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadedUrls, [url], "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedFeedCommentsReload()
		XCTAssertEqual(loader.loadedUrls, [url, url], "Expected another loading request once user initiates a reload")
		
		sut.simulateUserInitiatedFeedCommentsReload()
		XCTAssertEqual(loader.loadedUrls, [url, url, url], "Expected yet another loading request once user initiates another reload")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedCommentsViewController(url: url, loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
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
		var loadedUrls: [URL] = []
		func load(url: URL, completion: @escaping (FeedCommentsLoader.Result) -> Void) {
			loadedUrls.append(url)
		}
	}
}

extension FeedCommentsViewController {
	func simulateUserInitiatedFeedCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
}

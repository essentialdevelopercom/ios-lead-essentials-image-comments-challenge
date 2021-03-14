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
		loader.load(url: url, completion: {[weak self] _ in
			self?.refreshControl?.endRefreshing()
		})
		refreshControl?.beginRefreshing()
	}
	
	@objc private func refresh() {
		refreshControl?.beginRefreshing()
		loader.load(url: url, completion: {[weak self] _ in
			self?.refreshControl?.endRefreshing()
		})
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
	
	func test_loadingFeedCommentsIndicator_isVisibleWhileLoadingFeedComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
		
		sut.simulateUserInitiatedFeedCommentsReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
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
		
		private(set) var loadedUrls: [URL] = []
		private var commentsRequests: [(FeedCommentsLoader.Result) -> Void] = []
		
		func load(url: URL, completion: @escaping (FeedCommentsLoader.Result) -> Void) {
			loadedUrls.append(url)
			commentsRequests.append(completion)
		}
		
		func completeCommentsLoading(with comments: [FeedComment] = [], at index: Int = 0) {
			commentsRequests[index](.success(comments))
		}
		
		func completeCommentsLoadingWithError(at index: Int = 0) {
			commentsRequests[index](.failure(anyNSError()))
		}
	}
}

extension FeedCommentsViewController {
	func simulateUserInitiatedFeedCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
}

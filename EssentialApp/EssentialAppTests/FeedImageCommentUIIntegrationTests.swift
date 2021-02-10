//
//  FeedImageCommentUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Mario Alberto Barragán Espinosa on 09/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedImageCommentViewController: UITableViewController {
	private var loader: FeedImageCommentLoader?
	private var url: URL?
	
	convenience init(loader: FeedImageCommentLoader, url: URL) {
		self.init()
		self.loader = loader
		self.url = url
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		load()
	}
	
	@objc private func load() {
		refreshControl?.beginRefreshing()
		_ = loader?.loadImageCommentData(from: url!) { [weak self] _ in 
			self?.refreshControl?.endRefreshing()
		}
	}
}

class FeedImageCommentUIIntegrationTests: XCTestCase {
	
	func test_loadFeedCommentActions_requestFeedCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertTrue(loader.loadedImageCommentURLs.isEmpty, 
					  "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadedImageCommentURLs, [anyURL()], 
					   "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedFeedCommentReload()
		XCTAssertEqual(loader.loadedImageCommentURLs, [anyURL(), anyURL()], 
					   "Expected another loading request once user initiates a reload")
		
		sut.simulateUserInitiatedFeedCommentReload()
		XCTAssertEqual(loader.loadedImageCommentURLs, [anyURL(), anyURL(), anyURL()], 
					   "Expected yet another loading request once user initiates another reload")
	}
	
	func test_loadingFeedCommentIndicator_isVisibleWhileLoadingFeedComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeFeedCommentLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
		
		sut.simulateUserInitiatedFeedCommentReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeFeedCommentLoading(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageCommentViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedImageCommentViewController(loader: loader, url: url)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	class LoaderSpy: FeedImageCommentLoader {
		
		// MARK:- FeedImageCommentLoader
		
		private struct TaskSpy: FeedImageCommentLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}
		
		private var imageCommentRequests = [(url: URL, completion: (FeedImageCommentLoader.Result) -> Void)]()
		
		var loadedImageCommentURLs: [URL] {
			return imageCommentRequests.map { $0.url }
		}
				
		func loadImageCommentData(from url: URL, completion: @escaping (Result<[FeedImageComment], Error>) -> Void) -> FeedImageCommentLoaderTask {
			imageCommentRequests.append((url, completion))
			return TaskSpy { }
		}
		
		func completeFeedCommentLoading(with feedComments: [FeedImageComment] = [], at index: Int = 0) {
			imageCommentRequests[index].completion(.success(feedComments))
		}
	}
}


private extension FeedImageCommentViewController {
	func simulateUserInitiatedFeedCommentReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
}

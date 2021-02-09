//
//  FeedImageCommentUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Mario Alberto Barragán Espinosa on 09/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedImageCommentViewController {
	init(loader: FeedImageCommentLoader) {
		
	}
}

class FeedImageCommentUIIntegrationTests: XCTestCase {
	
	func test_init_doesNotLoadFeedImageComments() {
		let loader = LoaderSpy()
		let _ = FeedImageCommentViewController(loader: loader)
		
		XCTAssertEqual(loader.loadedImageCommentURLs.count, 0)
	}
	
	// MARK: - Helpers
	
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
			return TaskSpy { }
		}
	}
}

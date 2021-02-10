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

final class FeedImageCommentViewController: UIViewController {
	private var loader: FeedImageCommentLoader?
	private var url: URL?
	
	convenience init(loader: FeedImageCommentLoader, url: URL) {
		self.init()
		self.loader = loader
		self.url = url
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_ = loader?.loadImageCommentData(from: url!) { _ in }
	}
}

class FeedImageCommentUIIntegrationTests: XCTestCase {
	
	func test_init_doesNotLoadFeedImageComments() {
		let loader = LoaderSpy()
		let _ = FeedImageCommentViewController(loader: loader, url: anyURL())
		
		XCTAssertEqual(loader.loadedImageCommentURLs.count, 0)
	}
	
	func test_viewDidLoad_loadsComments() {
		let loader = LoaderSpy()
		let sut = FeedImageCommentViewController(loader: loader, url: anyURL())
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadedImageCommentURLs, [anyURL()])
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
			imageCommentRequests.append((url, completion))
			return TaskSpy { }
		}
	}
}

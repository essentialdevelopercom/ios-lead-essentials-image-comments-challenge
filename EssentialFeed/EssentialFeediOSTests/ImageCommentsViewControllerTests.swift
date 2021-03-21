//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ángel Vázquez on 20/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest
import UIKit

class ImageCommentsViewController: UITableViewController {
	
	private var url: URL!
	private var loader: ImageCommentLoader?
	
	convenience init(url: URL, loader: ImageCommentLoader) {
		self.init()
		self.url = url
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		refreshControl?.beginRefreshing()
		
		load()
	}
	
	@objc private func load() {
		_ = loader?.load(from: url) { [weak self] _ in
			self?.refreshControl?.endRefreshing()
		}
	}
}

class ImageCommentsViewControllerTests: XCTestCase {
	func test_init_doesNotLoadComments() {
		let url = URL(string: "https://any-url.com")!
		let (_, loader) = makeSUT(url: url)
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	func test_viewDidLoad_loadsComments() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadCallCount, 1)
	}
	
	func test_pullToRefresh_loadsComments() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		sut.loadViewIfNeeded()
		
		sut.refreshControl?.simulatePullToRefresh()
		XCTAssertEqual(loader.loadCallCount, 2)
		
		sut.refreshControl?.simulatePullToRefresh()
		XCTAssertEqual(loader.loadCallCount, 3)
	}
	
	func test_viewDidLoad_showsLoadingSpinner() {
		let url = URL(string: "https://any-url.com")!
		let (sut, _) = makeSUT(url: url)
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
	}
	
	func test_viewDidLoad_hidesLoadingSpinnerOnLoaderCompletion() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading()
		
		XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
	}
	
	func test_pullToRefresh_showsLoadingSpinner() {
		let url = URL(string: "https://any-url.com")!
		let (sut, _) = makeSUT(url: url)
		
		sut.refreshControl?.simulatePullToRefresh()
		
		XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
	}
	
	func test_pullToRefresh_hidesLoadingSpinnerOnLoaderCompletion() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		
		sut.refreshControl?.simulatePullToRefresh()
		loader.completeCommentsLoading()
		
		XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
	}
	// MARK: - Helpers
	
	private func makeSUT(url: URL, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsViewController(url: url, loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	class LoaderSpy: ImageCommentLoader {
		private(set) var loadCallCount = 0
		
		private var messages = [(url: URL, completion: (ImageCommentLoader.Result) -> Void)]()
		
		private var completions: [(ImageCommentLoader.Result) -> Void] {
			messages.map { $0.completion }
		}
		
		struct Task: ImageCommentLoaderTask {
			func cancel() { }
		}
		
		func load(from url: URL, completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderTask {
			messages.append((url, completion))
			loadCallCount += 1
			return Task()
		}
		
		func completeCommentsLoading() {
			completions[0](.success([]))
		}
	}
}

extension UIControl {
	func simulate(event: UIControl.Event) {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: event)?.forEach {
				(target as NSObject).perform(Selector($0))
			}
		}
	}
}

extension UIRefreshControl {
	func simulatePullToRefresh() {
		simulate(event: .valueChanged)
	}
}


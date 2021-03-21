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
		
		XCTAssertTrue(loader.requestedURLs.isEmpty)
	}
	
	func test_viewDidLoad_loadsComments() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.requestedURLs, [url])
	}
	
	func test_userInitiatedReloading_loadsComments() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		sut.loadViewIfNeeded()
		
		sut.simulateUserInitiatedReloading()
		XCTAssertEqual(loader.requestedURLs, [url, url])
		
		sut.simulateUserInitiatedReloading()
		XCTAssertEqual(loader.requestedURLs, [url, url, url])
	}
	
	func test_viewDidLoad_showsLoadingSpinner() {
		let url = URL(string: "https://any-url.com")!
		let (sut, _) = makeSUT(url: url)
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingSpinner)
	}
	
	func test_viewDidLoad_hidesLoadingSpinnerOnLoaderCompletion() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading()
		
		XCTAssertFalse(sut.isShowingLoadingSpinner)
	}
	
	func test_userInitiatedReloading_showsLoadingSpinner() {
		let url = URL(string: "https://any-url.com")!
		let (sut, _) = makeSUT(url: url)
		
		sut.simulateUserInitiatedReloading()
		
		XCTAssertTrue(sut.isShowingLoadingSpinner)	}
	
	func test_userInitiatedReloading_hidesLoadingSpinnerOnLoaderCompletion() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		
		sut.simulateUserInitiatedReloading()
		loader.completeCommentsLoading()
		
		XCTAssertFalse(sut.isShowingLoadingSpinner)
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
		private var messages = [(url: URL, completion: (ImageCommentLoader.Result) -> Void)]()
		
		private var completions: [(ImageCommentLoader.Result) -> Void] {
			messages.map { $0.completion }
		}
		
		var requestedURLs: [URL] {
			messages.map { $0.url }
		}
		
		struct Task: ImageCommentLoaderTask {
			func cancel() { }
		}
		
		func load(from url: URL, completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderTask {
			messages.append((url, completion))
			return Task()
		}
		
		func completeCommentsLoading() {
			completions[0](.success([]))
		}
	}
}

extension ImageCommentsViewController {
	var isShowingLoadingSpinner: Bool {
		refreshControl?.isRefreshing == true
	}
	
	func simulateUserInitiatedReloading() {
		refreshControl?.simulatePullToRefresh()
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


//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Alok Subedi on 04/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed

class ImageCommentsViewController: UITableViewController {
	private var loader: ImageCommentsViewControllerTests.LoaderSpy?
	
	convenience init(loader: ImageCommentsViewControllerTests.LoaderSpy) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		
		load()
	}
	
	@objc func load() {
		self.refreshControl?.beginRefreshing()
		loader?.load() { [weak self] _ in
			self?.refreshControl?.endRefreshing()
		}
	}
}

class ImageCommentsViewControllerTests: XCTestCase {

	func test_init_doesNotRequestLoadImageComments() {
		let (_, loader) = makeSUT()
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	func test_loadImmageCommentsAction_requestsToLoadImageComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1)
		
		sut.refreshControl?.simulatePullToRefresh()
		XCTAssertEqual(loader.loadCallCount, 2)
		
		sut.refreshControl?.simulatePullToRefresh()
		XCTAssertEqual(loader.loadCallCount, 3)
	}
	
	func test_loadingIndicator_isVisibleWhileLoadingImageComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator)
		
		loader.completeLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator)
		
		sut.refreshControl?.simulatePullToRefresh()
		XCTAssertTrue(sut.isShowingLoadingIndicator)
		
		loader.completeLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator)
	}
	
	//MARK: Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsViewController(loader: loader)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		
		return (sut, loader)
	}
	
	class LoaderSpy: ImageCommentsLoader {
		private var imageCommentsRequests = [(ImageCommentsLoader.Result) -> Void]()
		var loadCallCount: Int {
			return imageCommentsRequests.count
		}
		
		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) {
			imageCommentsRequests.append((completion))
		}
		
		func completeLoading(at index: Int) {
			imageCommentsRequests[index](.success([]))
		}
		
		func completeLoadingWithError(at index: Int) {
			imageCommentsRequests[index](.failure(NSError()))
		}
	}
}

private extension ImageCommentsViewController {
	var isShowingLoadingIndicator: Bool {
		return self.refreshControl?.isRefreshing == true
	}
}

private extension UIRefreshControl {
	func simulatePullToRefresh() {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
				(target as NSObject).perform(Selector($0))
			}
		}
	}
}

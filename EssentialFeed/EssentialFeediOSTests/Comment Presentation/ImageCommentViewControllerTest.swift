//
//  ImageCommentViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Mayorga on 3/17/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed

final class ImageCommentViewController: UITableViewController {
	private var loader: ImageCommentLoader?
	
	convenience init(loader: ImageCommentLoader) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.beginRefreshing()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		
		load()
	}
	
	@objc func load() {
		loader?.load(completion: { [weak self] result in
			self?.refreshControl?.endRefreshing()
		})
	}
}

class ImageCommentViewControllerTest: XCTestCase {
	func test_loadCommentActions_requestCommentFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCallCount, 0)
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1)
	}
	
	func test_viewDidLoad_displaysLoadingIndicator() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertTrue(sut.isShowingLoadingIndicator)
	}
	
	func test_viewDidLoad_hidesLoadingIndicator() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentLoading()
		
		XCTAssertFalse(sut.isShowingLoadingIndicator)
	}
	
	func test_refreshAction_loadCommentsManually() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		refreshAction(sut: sut)
		XCTAssertEqual(loader.loadCallCount, 2)
		
		refreshAction(sut: sut)
		XCTAssertEqual(loader.loadCallCount, 3)
	}
	
	func test_refreshAction_displaysLoadingIndicator() {
		let (sut, _) = makeSUT()
		
		refreshAction(sut: sut)
		
		XCTAssertTrue(sut.isShowingLoadingIndicator)
	}
	
	func test_refreshAction_hidesLoadingIndicatorWhenDone() {
		let (sut, loader) = makeSUT()
		
		refreshAction(sut: sut)
		loader.completeCommentLoading()
		
		XCTAssertFalse(sut.isShowingLoadingIndicator)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentViewController(loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func refreshAction(sut: ImageCommentViewController) {
		sut.refreshControl?.allTargets.forEach({ (target) in
			sut.refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ (target as NSObject).perform(Selector($0))
			})
		})
	}
	
	class LoaderSpy: ImageCommentLoader {
		private var completions = [(LoadImageCommentResult) -> Void]()
		var loadCallCount: Int { return completions.count }
		
		func load(completion: @escaping (LoadImageCommentResult) -> Void) {
			completions.append(completion)
		}
		
		func completeCommentLoading() {
			completions[0](.success([]))
		}
	}
}

private extension ImageCommentViewController {
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
}

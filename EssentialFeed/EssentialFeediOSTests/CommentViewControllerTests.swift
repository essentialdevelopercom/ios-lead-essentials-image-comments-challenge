//
//  CommentViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Khoi Nguyen on 30/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
import EssentialFeed
import UIKit


public class CommentViewController: UITableViewController {
	private var loader: CommentLoader?
	
	convenience init(loader: CommentLoader) {
		self.init()
		self.loader = loader
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		load()
	}
	
	@objc private func load() {
		refreshControl?.beginRefreshing()
		
		loader?.load { [weak self]_ in
			self?.refreshControl?.endRefreshing()
		}
	}
}

class CommentViewControllerTests: XCTestCase {
	
	func test_loadCommentAction_requestsCommentFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading request before the view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1, "Expected a request once the view is loaded")
		
		sut.simulateUserInititateCommentReload()
		XCTAssertEqual(loader.loadCallCount, 2, "Expected another request once user initiates a load")
		
		sut.simulateUserInititateCommentReload()
		XCTAssertEqual(loader.loadCallCount, 3, "Expected a third request once user initiates another load")
	}
	
	func test_loadingCommentIndicator_isVisibleWhileLoadingComment() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
	
		loader.completeCommentLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
		
		sut.simulateUserInititateCommentReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user intiates a reload")
		
		loader.completeCommentLoading(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user intitiated reload is completed")
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CommentViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = CommentViewController(loader: loader)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		
		return (sut, loader)
	}
	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}
	
	class LoaderSpy: CommentLoader {
		var loadCallCount: Int {
			return completions.count
		}
		var completions = [(CommentLoader.Result) -> Void]()
		func load(completion: @escaping (CommentLoader.Result) -> Void) {
			completions.append(completion)
		}
		
		func completeCommentLoading(at index: Int = 0) {
			completions[index](.success([]))
		}
	}
}

private extension CommentViewController {
	func simulateUserInititateCommentReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
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


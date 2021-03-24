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
	private var errorView: UIView?
	private var tableModel = [ImageComment]()
	
	convenience init(loader: ImageCommentLoader) {
		self.init()
		self.loader = loader
		self.errorView = UIView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.beginRefreshing()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		
		load()
		errorView?.isHidden = true
	}
	
	@objc func load() {
		loader?.load(completion: { [weak self] result in
			switch result {
			
				case .failure(_):
					self?.errorView?.isHidden = false
					
				case .success(let imageComments):
					self?.tableModel = imageComments
			}
			
			self?.refreshControl?.endRefreshing()
		})
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
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
		XCTAssertEqual(loader.loadCallCount, 1)
		
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
	
	func test_viewDidLoad_hidesErrorMessage() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertFalse(sut.isShowingErrorView)
	}
	
	func test_loadCommentActions_failedToLoadCommentsShowsErrorMessage() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.failedCommentLoading()
		
		XCTAssertTrue(sut.isShowingErrorView)
	}
	
	func test_loadCommentActions_hideErrorMessageOnSuccessfulLoad() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentLoading()
		
		XCTAssertFalse(sut.isShowingErrorView)
	}
	
	func test_loadCommentActions_displaysCorrectNumberOfRetrievedComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		let imageComment1 = makeImageComment(message: "message1", authorName: "author1")
		let imageComment2 = makeImageComment(message: "message2", authorName: "author2")
		let imageComment3 = makeImageComment(message: "message3", authorName: "author3")
		
		loader.completeCommentLoading(with: [imageComment1, imageComment2, imageComment3])
		
		XCTAssertEqual(sut.numberOfRenderedImageCommentViews(), 3)
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
	
	private func makeImageComment(message: String, date: Date = Date(), authorName: String) -> ImageComment {
		let author = ImageCommentAuthor(username: authorName)
		let imageComment = ImageComment(id: UUID(),
										message: message,
										createdAt: date,
										author: author)
		return imageComment
	}
	
	class LoaderSpy: ImageCommentLoader {
		private var completions = [(LoadImageCommentResult) -> Void]()
		var loadCallCount: Int { return completions.count }
		
		func load(completion: @escaping (LoadImageCommentResult) -> Void) {
			completions.append(completion)
		}
		
		func completeCommentLoading(with imageComments: [ImageComment] = []) {
			completions[0](.success(imageComments))
		}
		
		func failedCommentLoading() {
			completions[0](.failure(anyNSError()))
		}
	}
}

private extension ImageCommentViewController {
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	var isShowingErrorView: Bool {
		return errorView?.isHidden != true
	}
	
	func numberOfRenderedImageCommentViews() -> Int {
		return tableView.numberOfRows(inSection: imageCommentViews)
	}
	
	private var imageCommentViews: Int {
		return 0
	}
}

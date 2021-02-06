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
import EssentialFeediOS

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
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedImageComments() {
		let imageComment0 = makeComment(id: UUID(), message: "message", created_at: Date(), username: "user")
		let imageComment1 = makeComment(id: UUID(), message: "another message", created_at: Date(), username: "another user")
		let imageComment2 = makeComment(id: UUID(), message: "third message", created_at: Date(), username: "third user")
		let imageComment3 = makeComment(id: UUID(), message: "fourth message", created_at: Date(), username: "fourth user")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeLoading(with: [imageComment0], at: 0)
		assertThat(sut, isRendering: [imageComment0])
		
		sut.refreshControl?.simulatePullToRefresh()
		loader.completeLoading(with: [imageComment0, imageComment1, imageComment2, imageComment3], at: 1)
		assertThat(sut, isRendering: [imageComment0, imageComment1, imageComment2, imageComment3])
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedEmptyImageCommentsAfterNonEmptyImageComments() {
		let imageComment0 = makeComment(id: UUID(), message: "message", created_at: Date(), username: "user")
		let imageComment1 = makeComment(id: UUID(), message: "another message", created_at: Date(), username: "another user")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeLoading(with: [imageComment0, imageComment1], at: 0)
		assertThat(sut, isRendering: [imageComment0, imageComment1])
		
		sut.refreshControl?.simulatePullToRefresh()
		loader.completeLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	func test_loadImageCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let imageComment0 = makeComment(id: UUID(), message: "message", created_at: Date(), username: "user")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeLoading(with: [imageComment0], at: 0)
		assertThat(sut, isRendering: [imageComment0])
		
		sut.refreshControl?.simulatePullToRefresh()
		loader.completeLoadingWithError(at: 1)
		assertThat(sut, isRendering: [imageComment0])
	}
	
	func test_loadImageCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR"))
		
		sut.refreshControl?.simulatePullToRefresh()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	//MARK: Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		
		return (sut, loader)
	}
	
	private func makeComment(id: UUID, message: String, created_at: Date, username: String) -> ImageComment {
		let author = CommentAuthor(username: username)
		let comment = ImageComment(id: id, message: message, createdDate: created_at, author: author)
		
		return comment
	}
	
	private func relativeDateStringFromNow(to date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDateString = formatter.localizedString(for: date, relativeTo: Date())
		return relativeDateString
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, isRendering imageComments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
		XCTAssertEqual(sut.numberOfRenderedImageCommentsViews, imageComments.count, file: file, line: line)
		
		imageComments.enumerated().forEach { index, comment in
			let cell = sut.renderedCell(at: index)
			XCTAssertEqual(cell?.usernameText, comment.author.username, file: file, line: line)
			XCTAssertEqual(cell?.createdTimetext, relativeDateStringFromNow(to: comment.createdDate), file: file, line: line)
			XCTAssertEqual(cell?.messageText, comment.message, file: file, line: line)
		}
	}
	
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	class LoaderSpy: ImageCommentsLoader {
		private var imageCommentsRequests = [(ImageCommentsLoader.Result) -> Void]()
		var loadCallCount: Int {
			return imageCommentsRequests.count
		}
		
		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) {
			imageCommentsRequests.append((completion))
		}
		
		func completeLoading(with comments: [ImageComment] = [], at index: Int) {
			imageCommentsRequests[index](.success(comments))
		}
		
		func completeLoadingWithError(at index: Int) {
			imageCommentsRequests[index](.failure(NSError()))
		}
	}
}

private extension ImageCommentsViewController {
	private var errorView: UILabel? {
		return tableView.tableHeaderView as? UILabel
	}
	
	var errorMessage: String? {
		return errorView?.text
	}
	
	func renderedCell(at row: Int) -> ImageCommentsCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: imageCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentsCell
	}
	
	var isShowingLoadingIndicator: Bool {
		return self.refreshControl?.isRefreshing == true
	}
	
	var numberOfRenderedImageCommentsViews: Int {
		return tableView.numberOfRows(inSection: imageCommentsSection)
	}
	
	private var imageCommentsSection: Int { 0 }
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

private extension ImageCommentsCell {
	var usernameText: String? {
		return usernameLabel.text
	}
	
	var messageText: String? {
		return message.text
	}
	
	var createdTimetext: String? {
		return createdTimeLabel.text
	}
}

//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ángel Vázquez on 20/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import XCTest
import UIKit

class ImageCommentsViewControllerTests: XCTestCase {
	func test_loadCommentsActions_requestsLoadingCommentsFromURL() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		XCTAssertTrue(loader.requestedURLs.isEmpty, "Expected no loading requests upon creation")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.requestedURLs, [url], "Expected a single loading request when view has loaded")
		
		sut.simulateUserInitiatedReloading()
		XCTAssertEqual(loader.requestedURLs, [url, url], "Expected a second loading request once user initiates a reload")
		
		sut.simulateUserInitiatedReloading()
		XCTAssertEqual(loader.requestedURLs, [url, url, url], "Expected a third loading request once user initiates another reload")
	}
	
	func test_loadingSpinner_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT(url: anyURL())
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingSpinner, "Expected loading spinner to be shown when view has loaded")
		
		loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingSpinner, "Expected loading spinner to stop animating upon loader completion")
		
		sut.simulateUserInitiatedReloading()
		XCTAssertTrue(sut.isShowingLoadingSpinner, "Expected loading spinner to start animating once user requests a reload")
		
		loader.completeCommentsLoading(at: 1)
		XCTAssertFalse(sut.isShowingLoadingSpinner, "Expected loading spinner to stop animating upon loader completion")
	}
	
	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let staticDate = makeDateFromTimestamp(1_605_868_247, description: "2020-11-20 10:30:47 +0000")
		
		let comment0 = makeComment(
			message: "a message",
			creationDate: makeDateFromTimestamp(1_605_860_313, description: "2020-11-20 08:18:33 +0000"),
			author: "an author"
		)
		let expectedRelativeDate0 = "2 hours ago"
		
		let comment1 = makeComment(
			message: "another message",
			creationDate: makeDateFromTimestamp(1_605_713_544, description: "2020-11-18 15:32:24 +0000"),
			author: "a second author"
		)
		let expectedRelativeDate1 = "1 day ago"
		
		let comment2 = makeComment(
			message: "another message",
			creationDate: makeDateFromTimestamp(1_604_571_429, description: "2020-11-05 10:17:09 +0000"),
			author: "a third author"
		)
		let expectedRelativeDate2 = "2 weeks ago"
		
		let comment3 = makeComment(
			message: "a fourth message",
			creationDate: makeDateFromTimestamp(1_602_510_149, description: "2020-10-12 13:42:29 +0000"),
			author: "another author"
		)
		let expectedRelativeDate3 = "1 month ago"
		
		let comment4 = makeComment(
			message: "a fifth message",
			creationDate: makeDateFromTimestamp(1_488_240_000, description: "2017-02-28 00:00:00 +0000"),
			author: "a fifth author"
		)
		let expectedRelativeDate4 = "3 years ago"
		
		
		let (sut, loader) = makeSUT(url: anyURL(), currentDate: { staticDate })
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [(comment0, expectedRelativeDate0)])
		
		sut.simulateUserInitiatedReloading()
		loader.completeCommentsLoading(with: [comment0, comment1, comment2, comment3, comment4], at: 1)
		assertThat(sut, isRendering: [
			(comment0, expectedRelativeDate0),
			(comment1, expectedRelativeDate1),
			(comment2, expectedRelativeDate2),
			(comment3, expectedRelativeDate3),
			(comment4, expectedRelativeDate4)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL, currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsViewController(url: url, currentDate: currentDate, loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, isRendering pairs: [(comment: ImageComment, relativeDate: String)], file: StaticString = #filePath, line: UInt = #line) {
		guard sut.numberOfRenderedComments() == pairs.count else {
			return XCTFail("Expected \(pairs.count) images, got \(sut.numberOfRenderedComments()) instead.", file: file, line: line)
		}
		
		pairs.enumerated().forEach { index, pair in
			assertThat(sut, hasViewConfiguredFor: pair, at: index, file: file, line: line)
		}
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor pair: (comment: ImageComment, relativeDate: String), at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: self)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.authorText, pair.comment.author, "Expected author to be \(pair.comment.author) for comment view at index \(index)", file: file, line: line)
		
		XCTAssertEqual(cell.messageText, pair.comment.message, "Expected message to be \(pair.comment.message) for comment view at index \(index)", file: file, line: line)
		
		XCTAssertEqual(cell.creationDateText, pair.relativeDate, "Expected relative date to be \(pair.relativeDate) for comment view at index \(index)", file: file, line: line)
	}
	
	private func makeDateFromTimestamp(_ timestamp: TimeInterval, description: String, file: StaticString = #file, line: UInt = #line) -> Date {
		let date = Date(timeIntervalSince1970: timestamp)
		XCTAssertEqual(date.description, description, file: file, line: line)
		return date
	}
	
	private func anyURL() -> URL {
		URL(string: "https://any-url.com")!
	}
	
	private func makeComment(message: String, creationDate: Date, author: String) -> ImageComment {
		ImageComment(id: UUID(), message: message, creationDate: creationDate, author: author)
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
		
		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			completions[index](.success(comments))
		}
	}
}

extension ImageCommentsViewController {
	private var commentsSection: Int {
		0
	}
	
	var isShowingLoadingSpinner: Bool {
		refreshControl?.isRefreshing == true
	}
	
	func simulateUserInitiatedReloading() {
		refreshControl?.simulatePullToRefresh()
	}
	
	func numberOfRenderedComments() -> Int {
		tableView.numberOfRows(inSection: commentsSection)
	}
	
	func imageCommentView(at row: Int) -> UITableViewCell? {
		let dataSource = tableView.dataSource
		let indexPath = IndexPath(row: row, section: commentsSection)
		return dataSource?.tableView(tableView, cellForRowAt: indexPath)
	}
}

extension ImageCommentCell {
	var authorText: String? {
		authorLabel.text
	}
	
	var creationDateText: String? {
		creationDateLabel.text
	}
	
	var messageText: String? {
		messageLabel.text
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


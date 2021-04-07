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
import EssentialFeediOS

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
		let (sut, _) = makeSUT()
		
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
	
	func test_loadCommentActions_displaysRetrievedComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.numberOfRenderedImageCommentViews(), 0)
		
		let imageComment1 = makeImageComment(comment: "message1", date: Date(), authorName: "author1")
		let imageComment2 = makeImageComment(comment: "message2", date: Date(), authorName: "author2")
		let imageComment3 = makeImageComment(comment: "message3", date: Date(), authorName: "author3")
		
		let imageCommentArray = [imageComment1, imageComment2, imageComment3]
		
		loader.completeCommentLoading(with: imageCommentArray)
		XCTAssertEqual(sut.numberOfRenderedImageCommentViews(), 3)
		
		imageCommentArray.enumerated().forEach { index, imageComment in
			let view = sut.imageCommentView(at: index) as? ImageCommentCell
			
			XCTAssertEqual(view?.authorNameText, imageComment.author.username)
			XCTAssertEqual(view?.commentText, imageComment.message)
			XCTAssertEqual(view?.dateText, imageComment.createdAt.relativeDate())
		}
	}
	
	func test_cancelLoad_cancelLoadCommentsWhenViewIsUnloaded() {
		let loader = LoaderSpy()
		var sut: ImageCommentViewController? = ImageCommentViewController(loader: loader)
		
		autoreleasepool {
			sut?.loadViewIfNeeded()
		}
		
		sut = nil
		
		XCTAssertEqual(loader.cancelledCompletions.count, 1)
	}
	
	func test_loadCommentActions_displaysCorrectRelativeDateFormatting() {
		let (sut, loader) = makeSUT()
		var view: ImageCommentCell
		
		sut.loadViewIfNeeded()
		
		view = makeImageCommentCell(to: sut, loader, .minute, -1)
		XCTAssertEqual(view.dateText, "1 minute ago")
		
		view = makeImageCommentCell(to: sut, loader, .minute, -2)
		XCTAssertEqual(view.dateText, "2 minutes ago")
		
		view = makeImageCommentCell(to: sut, loader, .hour, -1)
		XCTAssertEqual(view.dateText, "1 hour ago")
		
		view = makeImageCommentCell(to: sut, loader, .hour, -2)
		XCTAssertEqual(view.dateText, "2 hours ago")
		
		view = makeImageCommentCell(to: sut, loader, .day, -1)
		XCTAssertEqual(view.dateText, "1 day ago")
		
		view = makeImageCommentCell(to: sut, loader, .day, -2)
		XCTAssertEqual(view.dateText, "2 days ago")
		
		view = makeImageCommentCell(to: sut, loader, .month, -1)
		XCTAssertEqual(view.dateText, "1 month ago")
		
		view = makeImageCommentCell(to: sut, loader, .month, -2)
		XCTAssertEqual(view.dateText, "2 months ago")
		
		view = makeImageCommentCell(to: sut, loader, .year, -1)
		XCTAssertEqual(view.dateText, "1 year ago")
		
		view = makeImageCommentCell(to: sut, loader, .year, -2)
		XCTAssertEqual(view.dateText, "2 years ago")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let bundle = Bundle(for: ImageCommentViewController.self)
		let storyboard = UIStoryboard(name: "ImageComment", bundle: bundle)
		let sut = storyboard.instantiateInitialViewController() as! ImageCommentViewController
		sut.loader = loader
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
	
	private func makeImageComment(comment: String, date: Date = Date(), authorName: String) -> ImageComment {
		let author = ImageCommentAuthor(username: authorName)
		let imageComment = ImageComment(id: UUID(),
										message: comment,
										createdAt: date,
										author: author)
		return imageComment
	}
	
	func makeImageCommentCell(to sut: ImageCommentViewController, _ loader: LoaderSpy, _ calendarComponent: Calendar.Component, _ timeComponentValue: Int) -> ImageCommentCell {
		let todaysDate = Date()
		let relativeDate = Calendar(identifier: .gregorian).date(byAdding: calendarComponent, value: timeComponentValue, to: todaysDate)!
		let imageComment = makeImageComment(comment: "comment", date: relativeDate, authorName: "authorName")
		loader.completeCommentLoading(with: [imageComment])
		return sut.imageCommentView(at: 0) as! ImageCommentCell
	}
}
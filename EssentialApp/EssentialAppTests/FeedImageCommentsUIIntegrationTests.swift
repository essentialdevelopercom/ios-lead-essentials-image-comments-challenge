
//  Created by Maxim Soldatov on 11/29/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class FeedImageCommentsUIIntegrationTests: XCTestCase {
	
	func test_feedView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("FEED_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadCommentsAction_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedCommentsReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedCommentsReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}
	
	func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true)
		
		loader.completeCommentsLoading()
		XCTAssertEqual(sut.isShowingLoadingIndicator, false)
		
		sut.simulateUserInitiatedCommentsReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeCommentsLoading(with: anyNSError())
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	}
	
	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		
		let (sut, loader) = makeSUT()
		let comments = makeUniqComments()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: comments)
		
		assertThat(sut, isRendering: comments.toModels())
	}
	
	func test_loadFeedCompletion_rendersSuccessfullyLoadedCommentsAfterNonEmptyComments() {
		
		let (sut, loader) = makeSUT()
		let comments = makeUniqComments()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: comments, at: 0)
		assertThat(sut, isRendering: comments.toModels())
		
		sut.simulateUserInitiatedCommentsReload()
		loader.completeCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comments = makeUniqComments()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: comments, at: 0)
		assertThat(sut, isRendering: comments.toModels())
		
		sut.simulateUserInitiatedCommentsReload()
		loader.completeCommentsLoading(with: anyNSError(), at: 1)
		assertThat(sut, isRendering: comments.toModels())
	}
	
	func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeCommentsLoading(with: anyNSError())
		XCTAssertEqual(sut.errorMessage, localized("FEED_COMMENTS_VIEW_ERROR_MESSAGE"))
		
		sut.simulateUserInitiatedCommentsReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_deinit_cancelsRunningRequest() {
		var sut: FeedImageCommentsViewController?
		let loader = FeedCommentsLoaderSpy()
		autoreleasepool {
			sut = FeedImageCommentsUIComposer.imageCommentsComposeWith(commentsLoader: loader, url: anyURL())
			sut?.loadViewIfNeeded()
		}
		XCTAssertEqual(loader.cancelledRequestURLs.count, 0)
		sut = nil
		XCTAssertEqual(loader.cancelledRequestURLs.count, 1)
	}
	
	//MARK: -Helpers
	
	private func makeSUT(url: URL = anyURL(),file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageCommentsViewController, loader: FeedCommentsLoaderSpy) {
		let loader = FeedCommentsLoaderSpy()
		let sut = FeedImageCommentsUIComposer.imageCommentsComposeWith(commentsLoader: loader, url: url)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	func assertThat(_ sut: FeedImageCommentsViewController, isRendering comment: [FeedImageCommentPresentingModel], file: StaticString = #file, line: UInt = #line) {
		sut.tableView.layoutIfNeeded()
		RunLoop.main.run(until: Date())
		guard sut.numberOfRenderedFeedCommentViews() == comment.count else {
			return XCTFail("Expected \(comment.count) images, got \(sut.numberOfRenderedFeedCommentViews()) instead.", file: file, line: line)
		}
		
		comment.enumerated().forEach { index, comment in
			assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
		}
	}
	
	private func assertThat(_ sut: FeedImageCommentsViewController, hasViewConfiguredFor commentModel: FeedImageCommentPresentingModel, at index: Int, file: StaticString = #file, line: UInt = #line) {
		
		let view = sut.feedCommentView(at: index)
		
		guard let cell = view as? FeedImageCommentCell else {
			return XCTFail("Expected \(FeedImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.usernameLabelText, commentModel.username, file: file, line: line)
		XCTAssertEqual(cell.creationTimeText, commentModel.creationTime, file: file, line: line)
		XCTAssertEqual(cell.commentText, commentModel.comment, file: file, line: line)
	}
	
	private func makeUniqComments() -> [ImageComment] {
		let currentDate = Date()
		let comment1 = ImageComment(id: UUID(), message: "First message", createdAt: currentDate.adding(days: -2), author: "First Author")
		let comment2 = ImageComment(id: UUID(), message: "Second message", createdAt: currentDate.adding(seconds: -305), author: "Second Author")
		return [comment1, comment2]
	}
	
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "FeedImageComments"
		let bundle = Bundle(for: FeedImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}

}

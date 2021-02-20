//
//  FeedImageCommentLoaderPresenter.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 13/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

@testable import EssentialFeed
import XCTest

final class FeedImageCommentLoaderPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		XCTAssertEqual(FeedImageCommentLoaderPresenter.title, 
					   localized(for: FeedImageCommentLoaderPresenter.self,
								 "FEED_COMMENT_VIEW_TITLE"))
	}

    func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()

		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
	
	func test_didStartLoadingFeedComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()

		sut.didStartLoadingFeedComments()

		XCTAssertEqual(view.messages, [
						.display(errorMessage: .none),
						.display(isLoading: true)])
	}
	
	func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
		let (sut, view) = makeSUT()
		let (comments, viewModels) = uniqueImageFeedComments()

		sut.didFinishLoadingFeed(with: comments)

		XCTAssertEqual(view.messages, [
			.display(comments: viewModels),
			.display(isLoading: false)
		])
	}
	
	func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()

		sut.didFinishLoadingFeedComments(with: anyNSError())

		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized(for: FeedImageCommentLoaderPresenter.self,
											 "FEED_VIEW_CONNECTION_ERROR")),
			.display(isLoading: false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageCommentLoaderPresenter, view: ViewSpy){
		let view = ViewSpy()
		let sut = FeedImageCommentLoaderPresenter(feedCommentView: view, 
												  loadingView: view, 
												  errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func uniqueImageFeedComments() -> (models: [FeedImageComment], viewModels: [CommentItemViewModel]) {
		let models = [uniqueComment(), uniqueComment()]
		let viewModels = models.map { CommentItemViewModel(message: $0.message, 
													  authorName: $0.author, 
													  createdAt: FeedCommentDatePolicy.getRelativeDate(for: $0.creationDate)) }
		return (models, viewModels)
	}
	
	private func uniqueComment() -> FeedImageComment {
		return FeedImageComment(id: UUID(), 
								message: "message", 
								creationDate: Date(), 
								authorUsername: "any")
	}
	
	private class ViewSpy: FeedImageCommentView, FeedLoadingView, FeedErrorView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [CommentItemViewModel])
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: FeedCommentViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
		
		func display(_ viewModel: FeedLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: FeedErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
	}
}

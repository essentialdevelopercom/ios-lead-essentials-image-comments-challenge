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
	
	private class ViewSpy: FeedImageCommentView, FeedLoadingView, FeedErrorView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: FeedCommentViewModel) {
			
		}
		
		func display(_ viewModel: FeedLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: FeedErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
	}
}

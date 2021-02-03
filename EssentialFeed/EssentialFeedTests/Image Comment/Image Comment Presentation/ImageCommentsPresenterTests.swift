//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 03/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {

	func test_init_doesNotSendMessageToView() {
		let (_, view) = makeSUT()
		
		XCTAssertEqual(view.receivedMessages.isEmpty, true)
	}
	
	func test_didStartLoadingImageComments_startsLoadingAndDisplaysNoError() {
		let (sut, view) = makeSUT()

		sut.didStartLoadingImageComments()
		
		XCTAssertEqual(view.receivedMessages, [.display(isLoading: true), .display(errorMessage: nil)])
	}
	
	func test_didFinishLoadingImageComments_stopsLoadingAndDisplaysImageComments() {
		let (sut, view) = makeSUT()
		let comment = makeComment(id: UUID(), message: "a message", created_at: Date(), username: "user")

		sut.didFinishLoadingImageComments(with: [comment, comment])
		
		XCTAssertEqual(view.receivedMessages, [.display(isLoading: false), .display(comments: [comment, comment])])
	}
	
	func test_didFinishLoadingImageCommentsWithError_stopsLoadingAndDisplaysError() {
		let (sut, view) = makeSUT()
		let errorMessage = NSLocalizedString("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR",
											 tableName: "ImageComments",
											 bundle: Bundle(for: FeedPresenter.self),
											 comment: "Error message displayed when we can't load the image comments from the server")

		sut.didFinishLoadingImageComments(with: NSError())
		
		XCTAssertEqual(view.receivedMessages, [.display(isLoading: false), .display(errorMessage: errorMessage)])
	}
	
	//MARK: Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(imageCommentsView: view, loadingView: view, errorView: view)
		
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		return (sut, view)
	}
	
	private func makeComment(id: UUID, message: String, created_at: Date, username: String) -> ImageComment {
		let author = CommentAuthor(username: username)
		let comment = ImageComment(id: id, message: message, createdDate: created_at, author: author)
		
		return comment
	}
	
	class ViewSpy: ImageCommentsLoadingView, ImageCommentsErrorView, ImageCommentsView {
		enum Message: Equatable {
			case display(isLoading: Bool)
			case display(errorMessage: String?)
			case display(comments: [ImageComment])
		}
		var receivedMessages = [Message]()
		
		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			receivedMessages.append(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentsErrorViewModel) {
			receivedMessages.append(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: ImageCommentsViewModel) {
			receivedMessages.append(.display(comments: viewModel.comments))
		}
	}
}

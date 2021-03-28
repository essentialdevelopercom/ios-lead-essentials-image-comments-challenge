//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

struct PresentableImageComment: Equatable {
	let createdAt: String
	let message: String
	let author: String
}

struct ImageCommentsViewModel {
	let comments: [PresentableImageComment]
}

protocol ImageCommentsView {
	func display(_ viewModel: ImageCommentsViewModel)
}

struct ImageCommentsLoadingViewModel {
	let isLoading: Bool
}

protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

struct ImageCommentsErrorViewModel {
	let errorMessage: String?
}

protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

final class ImageCommentsPresenter {
	private let imageCommentsView: ImageCommentsView
	private let loadingView: ImageCommentsLoadingView
	private let errorView: ImageCommentsErrorView
	private let currentDate: Date
	
	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the image comments view")
	}
	
	private var errorMessage: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_CONNECTION_ERROR",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Error message when loading comments fails"
		)
	}
	
	public init(
		imageCommentsView: ImageCommentsView,
		loadingView: ImageCommentsLoadingView,
		errorView: ImageCommentsErrorView,
		currentDate: Date = Date()
	) {
		self.imageCommentsView = imageCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
		self.currentDate = currentDate
	}
	
	public func didStartLoadingComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentsErrorViewModel(errorMessage: nil))
	}
	
	public func didFinishLoading(with comments: [ImageComment]) {
		let presentableComments = comments.map { comment in
			PresentableImageComment(
				createdAt: relativeDate(from: comment.createdAt),
				message: comment.message,
				author: comment.author.username)
		}
		imageCommentsView.display(ImageCommentsViewModel(comments: presentableComments))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoading(with error: Error) {
		errorView.display(ImageCommentsErrorViewModel(errorMessage: errorMessage))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	private static var relativeDateFormatter: RelativeDateTimeFormatter {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		formatter.locale = .current
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}
	
	private func relativeDate(from date: Date) -> String {
		return ImageCommentsPresenter.relativeDateFormatter.localizedString(for: date, relativeTo: currentDate)
	}
}

final class ImageCommentsPresenterTests: XCTestCase {
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingComments_displaysNoErrorMessagesAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [.display(isLoading: true), .display(errorMessage: nil)])
	}
	
	func test_didFinishLoadingComments_displaysCommentsUsingRelativeTimesAndStopsLoading() {
		let fixedDate = anyDate()
		let (sut, view) = makeSUT(date: fixedDate)
		let comments = uniqueComments(currentDate: fixedDate)
		
		sut.didFinishLoading(with: comments.comments)
		
		XCTAssertEqual(view.messages, [.display(comments: comments.presentableComments), .display(isLoading: false)])
	}
	
	func test_didFinishLoadingCommentsWithError_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoading(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR")),
			.display(isLoading: false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(date: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(imageCommentsView: view, loadingView: view, errorView: view, currentDate: date)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private func uniqueComments(currentDate: Date) -> (comments: [ImageComment], presentableComments: [PresentableImageComment]) {
		let comments = [
			ImageComment(
				id: UUID(),
				message: "a message",
				createdAt: Date(timeIntervalSinceReferenceDate: currentDate.timeIntervalSinceReferenceDate - 60 * 60 * 24),
				author: ImageCommentAuthor(username: "a username")
			),
			ImageComment(
				id: UUID(),
				message: "another message",
				createdAt: Date(timeIntervalSinceReferenceDate: currentDate.timeIntervalSinceReferenceDate - 60 * 60),
				author: ImageCommentAuthor(username: "another username")
			),
		]
		
		let presentableComments = [
			PresentableImageComment(createdAt: "1 day ago", message: comments[0].message, author: comments[0].author.username),
			PresentableImageComment(createdAt: "1 hour ago", message: comments[1].message, author: comments[1].author.username)
		]
		
		return (comments, presentableComments)
	}
	
	private class ViewSpy: ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView {
		enum Message: Equatable {
			case display(comments: [PresentableImageComment])
			case display(isLoading: Bool)
			case display(errorMessage: String?)
		}
		
		private(set) var messages = [Message]()
		
		func display(_ viewModel: ImageCommentsViewModel) {
			messages.append(.display(comments: viewModel.comments))
		}
		
		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			messages.append(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentsErrorViewModel) {
			messages.append(.display(errorMessage: viewModel.errorMessage))
		}
	}
}

//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

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
		let locale = Locale(identifier: "en_US_POSIX")
		let calendar = Calendar(identifier: .gregorian)
		let (sut, view) = makeSUT(date: fixedDate, locale: locale, calendar: calendar)
		let comments = [
			makeComment(
			   message: "a message",
			   createdAt: Date(timeInterval: -dayInSeconds, since: fixedDate),
			   username: "a username"),
			makeComment(
			   message: "another message",
			   createdAt: Date(timeInterval: -hourInSeconds, since: fixedDate),
			   username: "another username")
		]
		
		let presentableComments = [
			PresentableImageComment(createdAt: "1 day ago", message: comments[0].message, author: comments[0].author.username),
			PresentableImageComment(createdAt: "1 hour ago", message: comments[1].message, author: comments[1].author.username)
		]
		
		sut.didFinishLoading(with: comments)
		
		XCTAssertEqual(view.messages, [.display(comments: presentableComments), .display(isLoading: false)])
	}
	
	func test_didFinishLoadingCommentsWithError_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoading(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR")),
			.display(isLoading: false)
		])
	}
	
	func test_map_transformsImageCommentsToPresentableImageComments () {
		let fixedDate = anyDate()
		let locale = Locale(identifier: "en_US_POSIX")
		let calendar = Calendar(identifier: .gregorian)
		
		let imageComments = [
			makeComment(
			   message: "a message",
			   createdAt: Date(timeInterval: -dayInSeconds, since: fixedDate),
			   username: "a username"),
			makeComment(
			   message: "another message",
			   createdAt: Date(timeInterval: -hourInSeconds, since: fixedDate),
			   username: "another username")
		]
		
		let results = ImageCommentsPresenter.map(imageComments, currentDate: { fixedDate }, locale: locale, calendar: calendar)
		
		XCTAssertEqual(results, [
			PresentableImageComment(createdAt: "1 day ago", message: imageComments[0].message, author: imageComments[0].author.username),
			PresentableImageComment(createdAt: "1 hour ago", message: imageComments[1].message, author: imageComments[1].author.username)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		date: Date = Date(),
		locale: Locale = .current,
		calendar: Calendar = .current,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(
			imageCommentsView: view,
			loadingView: view,
			errorView: view,
			locale: locale,
			calendar: calendar,
			currentDate: { date })
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func makeComment(message: String, createdAt: Date, username: String) -> ImageComment {
		ImageComment(id: UUID(), message: message, createdAt: createdAt, author: ImageCommentAuthor(username: username))
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
			messages.append(.display(errorMessage: viewModel.message))
		}
	}
}

private let hourInSeconds: TimeInterval = 3_600
private let dayInSeconds: TimeInterval = 24 * hourInSeconds

//
//  ImageCommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 26/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

struct ImageCommentViewModel {
	let author: String
	let message: String
	let creationDate: String
}

protocol ImageCommentView {
	func display(_ viewModel: ImageCommentViewModel)
}

final class ImageCommentPresenter {
	private let currentDate: () -> Date
	private let commentView: ImageCommentView
	
	init(currentDate: @escaping () -> Date, commentView: ImageCommentView) {
		self.currentDate = currentDate
		self.commentView = commentView
	}
	
	func didLoadComment(_ comment: ImageComment) {
		commentView.display(
			ImageCommentViewModel(
				author: comment.author,
				message: comment.message,
				creationDate: formatRelativeDate(for: comment.creationDate)
			)
		)
	}
	
	private func formatRelativeDate(for date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		return formatter.localizedString(for: date, relativeTo: currentDate())
	}
}


class ImageCommentPresenterTests: XCTestCase {
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty)
	}
	
	func test_didLoadComment_displaysCommentWithRelativeDateFormatting() {
		let staticDate = makeDateFromTimestamp(1_605_868_247, description: "2020-11-20 10:30:47 +0000")
		let (sut, view) = makeSUT(currentDate: { staticDate })
		let comment = makeComment(date: makeDateFromTimestamp(1_605_860_313, description: "2020-11-20 08:18:33 +0000"))
		let expectedRelativeDate = "2 hours ago"
		
		sut.didLoadComment(comment)
		
		XCTAssertEqual(view.messages, [.display(author: comment.author, message: comment.message, relativeDate: expectedRelativeDate)])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentPresenter(currentDate: currentDate, commentView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func makeDateFromTimestamp(_ timestamp: TimeInterval, description: String, file: StaticString = #file, line: UInt = #line) -> Date {
		let date = Date(timeIntervalSince1970: timestamp)
		XCTAssertEqual(date.description, description, file: file, line: line)
		return date
	}
	
	private func makeComment(date: Date) -> ImageComment {
		ImageComment(
			id: UUID(),
			message: "any message",
			creationDate: date,
			author: "any author"
		)
	}
	
	private class ViewSpy: ImageCommentView {
		enum Messages: Equatable {
			case display(author: String, message: String, relativeDate: String)
		}
		
		private(set) var messages = [Messages]()
		
		func display(_ viewModel: ImageCommentViewModel) {
			messages.append(
				.display(
					author: viewModel.author,
					message: viewModel.message,
					relativeDate: viewModel.creationDate
				)
			)
		}
	}
}

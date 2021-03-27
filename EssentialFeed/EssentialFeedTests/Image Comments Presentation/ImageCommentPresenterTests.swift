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
		let staticDate = dateFromTimestamp(1_605_868_247, description: "2020-11-20 10:30:47 +0000")
		let samples: [(comment: ImageComment, relativeDate: String)] = [
			(comment(date: dateFromTimestamp(1_605_860_313, description: "2020-11-20 08:18:33 +0000")), "2 hours ago"),
			(comment(date: dateFromTimestamp(1_605_713_544, description: "2020-11-18 15:32:24 +0000")), "1 day ago"),
			(comment(date: dateFromTimestamp(1_604_571_429, description: "2020-11-05 10:17:09 +0000")), "2 weeks ago"),
			(comment(date: dateFromTimestamp(1_602_510_149, description: "2020-10-12 13:42:29 +0000")), "1 month ago"),
			(comment(date: dateFromTimestamp(1_488_240_000, description: "2017-02-28 00:00:00 +0000")), "3 years ago")
		]
		
		samples.enumerated().forEach { index, pair in
			let (comment, relativeDate) = pair
			let (sut, view) = makeSUT(currentDate: { staticDate })
			
			sut.didLoadComment(comment)
			
			XCTAssertEqual(
				view.messages,
				[.display(author: comment.author, message: comment.message, relativeDate: relativeDate)],
				"Expected comment at index \(index) to have author '\(comment.author)', message '\(comment.message)' and relative date '\(relativeDate)'"
			)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentPresenter(currentDate: currentDate, commentView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func dateFromTimestamp(_ timestamp: TimeInterval, description: String, file: StaticString = #file, line: UInt = #line) -> Date {
		let date = Date(timeIntervalSince1970: timestamp)
		XCTAssertEqual(date.description, description, file: file, line: line)
		return date
	}
	
	private func comment(date: Date) -> ImageComment {
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

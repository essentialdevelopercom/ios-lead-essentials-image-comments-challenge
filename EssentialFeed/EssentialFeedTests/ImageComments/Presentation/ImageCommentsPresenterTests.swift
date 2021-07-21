//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("COMMENTS_VIEW_TITLE"))
	}

	func test_map_createsViewModel() {
		let comments = [
			ImageComment(id: UUID(), message: "first message", createdAt: Date().adding(days: -1), authorUserName: "first author name"),
			ImageComment(id: UUID(), message: "second message", createdAt: Date().adding(days: -15), authorUserName: "second author name")
		]
		let locale = Locale(identifier: "en_US_POSIX")
		let viewModel = ImageCommentsPresenter.map(comments, locale: locale)

		XCTAssertEqual(
			viewModel.comments,
			[
				ImageCommentViewModel(message: "first message", date: "1 day ago", authorUserName: "first author name"),
				ImageCommentViewModel(message: "second message", date: "2 weeks ago", authorUserName: "second author name")
			]
		)
	}

	// MARK: - Helpers

	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Comments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}

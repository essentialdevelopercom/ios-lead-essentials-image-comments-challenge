//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_TITLE"))
	}

	func test_map_createsViewModel() {
		let now = Date()
		let calendar = Calendar(identifier: .gregorian)
		let locale = Locale(identifier: "en_US_POSIX")
		let comments = [
			ImageComment(id: UUID(), message: "message1", createdAt: now.adding(minutes: -5), username: "username1"),
			ImageComment(id: UUID(), message: "message2", createdAt: now.adding(days: -1), username: "username2")
		]
		
		let viewModel = ImageCommentsPresenter.map(comments, currentDate: now, calendar: calendar, locale: locale)

		XCTAssertEqual(viewModel.comments, [
			ImageCommentViewModel(message: "message1", createdAt: "5 minutes ago", username: "username1"),
			ImageCommentViewModel(message: "message2", createdAt: "1 day ago", username: "username2")]
		)
	}

	// MARK: - Helpers

	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}

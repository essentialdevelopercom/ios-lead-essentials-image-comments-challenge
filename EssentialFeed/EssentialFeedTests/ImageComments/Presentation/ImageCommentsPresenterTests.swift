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
		let comments = uniqueComments()

		let viewModel = ImageCommentsPresenter.map(comments)

		XCTAssertEqual(viewModel.comments, comments)
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

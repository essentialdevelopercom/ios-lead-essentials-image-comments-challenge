//
//  CommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed


class CommentPresenterTests: XCTestCase {
	func test_title_isLocalized() {
		XCTAssertEqual(CommentPresenter.title, localized("COMMENT_VIEW_TITLE"))
	}
	
	// MARK: - Helpers
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Comment"
		let bundle = Bundle(for: CommentPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}

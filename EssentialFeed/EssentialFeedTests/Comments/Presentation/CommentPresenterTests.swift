//
//  CommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CommentPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		XCTAssertEqual(CommentsPresenter.title, localized("COMMENTS_VIEW_TITLE"))
	}
	
	// MARK: - Helpers
	
	private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
		let table = "Comments"
		let bundle = Bundle(for: CommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing loclized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}

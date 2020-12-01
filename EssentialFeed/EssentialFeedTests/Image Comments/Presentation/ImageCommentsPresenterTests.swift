//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Rakesh Ramamurthy on 01/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest

class ImageCommentsPresenter {
	public static var title: String { NSLocalizedString(
		"IMAGE_COMMENTS_VIEW_TITLE",
		tableName: "ImageComments",
		bundle: Bundle(for: ImageCommentsPresenter.self),
		comment: "Title for the image comments view"
	) }
}

class ImageCommentsPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
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

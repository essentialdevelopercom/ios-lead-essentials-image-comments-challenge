//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 15/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class ImageCommentsPresenterTests: XCTestCase {

	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}

	// MARK: - Helpers

	private func localized(
		_ key: String,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> String {
		EssentialFeedTests.localized(
			key: key,
			table: "ImageComments",
			bundle: Bundle(
				for: ImageCommentsPresenter.self
			)
		)
	}
}

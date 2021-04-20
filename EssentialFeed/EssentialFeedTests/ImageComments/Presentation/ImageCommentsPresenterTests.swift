//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sebastian Vidrea on 27.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
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

		let imageComments = [
			ImageComment(
				id: UUID(),
				message: "a message",
				createdAt: now.adding(minutes: -5),
				username: "a username"
			),
			ImageComment(
				id: UUID(),
				message: "another message",
				createdAt: now.adding(days: -5),
				username: "another username"
			)
		]

		let viewModel = ImageCommentsPresenter.map(
			imageComments,
			currentDate: now,
			calendar: calendar,
			locale: locale
		)

		XCTAssertEqual(viewModel.imageComments, [
			ImageCommentViewModel(message: "a message", username: "a username", createdAt: "5 minutes ago"),
			ImageCommentViewModel(message: "another message", username: "another username", createdAt: "5 days ago")
		])
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

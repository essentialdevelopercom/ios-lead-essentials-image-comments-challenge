//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Eric Garlock on 3/10/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsViewController : UITableViewController {
	
}

class ImageCommentsUIComposer {
	
	static func imageComments() -> ImageCommentsViewController {
		let viewController = ImageCommentsViewController()
		viewController.title = ImageCommentPresenter.title
		return viewController
	}
	
}

class ImageCommentsUIIntegrationTests: XCTestCase {

	func test_imageCommentsView_hasTitle() {
		let sut = makeSUT()
		
		XCTAssertEqual(sut.title, localized("COMMENT_VIEW_TITLE"))
	}
	
	// MARK: - Helpers
	private func makeSUT() -> ImageCommentsViewController {
		let sut = ImageCommentsUIComposer.imageComments()
		return sut
	}
	
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}

}

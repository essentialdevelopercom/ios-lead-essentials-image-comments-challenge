//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Lukas Bahrle Santana on 27/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed

class ImageCommentsViewController: UITableViewController{
	
}

class ImageCommentsUIComposer{
	static func imageComments() -> ImageCommentsViewController{
		let controller = ImageCommentsViewController()
		controller.title = ImageCommentsPresenter.title
		return controller
	}
}

final class ImageCommentsUIIntegrationTests: XCTestCase {
	func test_imageCommentsView_hasTitle() {
		let sut = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> ImageCommentsViewController {
		let sut = ImageCommentsUIComposer.imageComments()
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}

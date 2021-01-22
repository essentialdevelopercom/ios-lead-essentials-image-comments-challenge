//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Lukas Bahrle Santana on 22/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed


private class ViewSpy: ImageCommentsView{
	enum Message: Hashable {
	}
	
	private(set) var messages = Set<Message>()
	
}



class ImageCommentsPresenterTests: XCTestCase{
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_init_doesNotSendMessagesToView() {
		let view = ViewSpy()
		_ = ImageCommentsPresenter(imageCommentsView: view)
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	// MARK: - Helpers
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: FeedPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}

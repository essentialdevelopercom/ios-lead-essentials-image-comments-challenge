//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 03/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

class ImageCommentsPresenter {
	init() {
		
	}
}

class SomeView {
	var receivedMessagesCount = 0
}

class ImageCommentsPresenterTests: XCTestCase {

	func test_init_doesNotSendMessageToView() {
		let _ = ImageCommentsPresenter()
		let view = SomeView()
		
		XCTAssertEqual(view.receivedMessagesCount, 0)
	}
}

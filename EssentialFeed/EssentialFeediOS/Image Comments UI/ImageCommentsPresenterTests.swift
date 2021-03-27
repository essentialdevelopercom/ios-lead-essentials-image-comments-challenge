//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 26/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

final class ImageCommentsListPresenter {
	init(view: Any) {
		
	}
}

class ImageCommentsListPresenterTests: XCTestCase {
	func test_init_doesNotSendMessagesToView() {
		let view = ViewSpy()
		
		_ = ImageCommentsListPresenter(view: view)
		
		XCTAssertTrue(view.messages.isEmpty)
	}
	
	// MARK: - Helpers
	
	private class ViewSpy {
		let messages = [Any]()
	}
}



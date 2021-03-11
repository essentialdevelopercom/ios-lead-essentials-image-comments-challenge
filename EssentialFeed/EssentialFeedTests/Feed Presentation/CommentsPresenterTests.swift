//
//  CommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Anton Ilinykh on 11.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class CommentsPresenter {
	
}

class CommentsPresenterTests: XCTestCase {
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	//MARK: - Helpers
	
	private func makeSUT() -> (CommentsPresenter, ViewSPY) {
		let view = ViewSPY()
		let presenter = CommentsPresenter()
		return (presenter, view)
	}
	
	private final class ViewSPY {
		var messages = [Any]()
	}
}

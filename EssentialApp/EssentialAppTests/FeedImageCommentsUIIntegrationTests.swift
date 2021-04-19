//
//  FeedImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Danil Vassyakin on 4/19/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedImageCommentsUIIntegrationTests: XCTestCase {

	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, localized("FEED_COMMENT_TITLE"))
	}
	
	func test_loadImageCommentsAction_requestsCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.commentsCallCount, 0)

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.commentsCallCount, 1, "Expected to load when view did load")
	}

	
	// MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, locale: Locale = .current, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedUIComposer.feedCommentsComposedWith(commentLoader: loader.loadPublisher) as! FeedCommentsViewController
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

}

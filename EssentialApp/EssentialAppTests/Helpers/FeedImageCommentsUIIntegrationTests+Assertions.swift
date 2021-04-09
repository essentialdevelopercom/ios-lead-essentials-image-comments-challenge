//
//  FeedImageCommentsUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Ivan Ornes on 27/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedImageCommentsUIIntegrationTests {
	
	func assertThat(_ sut: FeedImageCommentsViewController, isRendering feed: [FeedImageComment], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		guard sut.numberOfRenderedFeedImageCommentViews() == feed.count else {
			return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageCommentViews()) instead.", file: file, line: line)
		}
		
		let viewModels = FeedImageCommentsPresenter.map(feed).comments

		viewModels.enumerated().forEach { index, viewModel in
			assertThat(sut, hasViewConfiguredFor: viewModel, at: index, file: file, line: line)
		}
		
		executeRunLoopToCleanUpReferences()
	}
	
	func assertThat(_ sut: FeedImageCommentsViewController, hasViewConfiguredFor commentViewModel: FeedImageCommentViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.feedImageCommentView(at: index)
		
		guard let cell = view else {
			return XCTFail("Expected \(FeedImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.messageText, commentViewModel.message, "message at index \(index)", file: file, line: line)
		
		XCTAssertEqual(cell.createdAtText, commentViewModel.creationDate, "'created at' date at index \(index)", file: file, line: line)
		
		XCTAssertEqual(cell.authorText, commentViewModel.author, "author at index \(index)", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
}

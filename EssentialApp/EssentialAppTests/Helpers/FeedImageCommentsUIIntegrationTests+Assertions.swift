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
		
		feed.enumerated().forEach { index, image in
			assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
		}
		
		executeRunLoopToCleanUpReferences()
	}
	
	func assertThat(_ sut: FeedImageCommentsViewController, hasViewConfiguredFor imageComment: FeedImageComment, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.feedImageCommentView(at: index)
		
		guard let cell = view else {
			return XCTFail("Expected \(FeedImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
	
		let viewSpy = ViewSpy()
		let presenter = FeedImageCommentsPresenter(feedImageCommentsView: viewSpy, loadingView: viewSpy, errorView: viewSpy, formatter: .init())
		
		presenter.didFinishLoadingComments(with: [imageComment])
		
		let commentViewModel = viewSpy.message(at: 0).comments.first!
		
		XCTAssertEqual(cell.messageText, commentViewModel.message, "message at index \(index)", file: file, line: line)
		
		XCTAssertEqual(cell.createdAtText, commentViewModel.creationDate, "'created at' date at index \(index)", file: file, line: line)
		
		XCTAssertEqual(cell.authorText, commentViewModel.author, "author at index \(index)", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
}

private class ViewSpy: FeedImageCommentsView, FeedLoadingView, FeedErrorView {
	private(set) var messages = Array<FeedImageCommentsViewModel>()
	
	func display(_ viewModel: FeedErrorViewModel) {
	}
	
	func display(_ viewModel: FeedLoadingViewModel) {
	}
	
	func display(_ viewModel: FeedImageCommentsViewModel) {
		messages.append(viewModel)
	}
	
	func message(at index: Int) -> FeedImageCommentsViewModel {
		return messages[index]
	}
}

//
//  FeedImageCommentLoaderPresenter.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 13/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

@testable import EssentialFeed
import XCTest

final class FeedImageCommentLoaderPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()

		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageCommentLoaderPresenter, view: ViewSpy){
		let view = ViewSpy()
		
		let sut = FeedImageCommentLoaderPresenter(feedCommentView: view, 
												  loadingView: view, 
												  errorView: view)
		
		return (sut, view)
	}
	
	private class ViewSpy: FeedImageCommentView, FeedLoadingView, FeedErrorView {
		let messages = [Any]()
		
		func display(_ viewModel: FeedCommentViewModel) {
			
		}
		
		func display(_ viewModel: FeedLoadingViewModel) {
			
		}
		
		func display(_ viewModel: FeedErrorViewModel) {
			
		}
	}
}

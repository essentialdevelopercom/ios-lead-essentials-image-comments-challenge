//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 03/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

struct ImageCommentsLoadingViewModel {
	let isLoading: Bool
}

protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

class ImageCommentsPresenter {
	let view: ImageCommentsLoadingView
	init(view: ImageCommentsLoadingView) {
		self.view = view
	}
	
	func didStartLoadingImageComments() {
		view.display(ImageCommentsLoadingViewModel(isLoading: true))
	}
}

class ImageCommentsPresenterTests: XCTestCase {

	func test_init_doesNotSendMessageToView() {
		let view = ViewSpy()
		let _ = ImageCommentsPresenter(view: view)
		
		XCTAssertEqual(view.receivedMessages.isEmpty, true)
	}
	
	func test_didStartLoadingImageComments_startsLoading() {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(view: view)
		
		sut.didStartLoadingImageComments()
		
		XCTAssertEqual(view.receivedMessages, [.display(isLoading: true)])
	}
	
	//MARK: Helpers
	
	class ViewSpy: ImageCommentsLoadingView {
		enum Message: Equatable {
			case display(isLoading: Bool)
		}
		var receivedMessages = [Message]()
		
		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			receivedMessages.append(.display(isLoading: viewModel.isLoading))
		}
	}
}

//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Anton Ilinykh on 12.07.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadResourcePresenterTests: XCTestCase {
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoading()
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}
	
	func test_didFinishLoading_displaysResourceAndStopsLoading() {
		let (sut, view) = makeSUT(mapper: { _ in "a mapped resource" })
		let resource = "a resource"
		
		sut.didFinishLoading(with: resource)
		
		XCTAssertEqual(view.messages, [
			.display(resource: "a mapped resource"),
			.display(isLoading: false)
		])
	}
	
	func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoading(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: loadError),
			.display(isLoading: false)
		])
	}
	
	// MARK: - Helpers
	
	private typealias SUT = LoadResourcePresenter<String, ViewSpy>
	
	private func makeSUT(
		mapper: @escaping SUT.Mapper = { _ in "any" },
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: SUT, view: ViewSpy) {
		let view = ViewSpy()
		let sut = SUT(resourceView: view, loadingView: view, errorView: view, mapper: mapper)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private class ViewSpy: ResourceView, FeedView, FeedLoadingView, FeedErrorView {
		typealias ResourceViewModel = String
		
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(feed: [FeedImage])
			case display(resource: String)
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ resource: String) {
			messages.insert(.display(resource: resource))
		}
		
		func display(_ viewModel: FeedErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: FeedLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: FeedViewModel) {
			messages.insert(.display(feed: viewModel.feed))
		}
	}
	
	private class DummyView: ResourceView {
		func display(_ viewModel: Any) {}
	}

	private var loadError: String {
		LoadResourcePresenter<Any, DummyView>.loadError
	}
}

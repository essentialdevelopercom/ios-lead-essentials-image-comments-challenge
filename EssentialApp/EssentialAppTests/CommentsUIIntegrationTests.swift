//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class CommentsUIIntegrationTests: XCTestCase {
	
	func test_commentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadCommentActions_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		
		XCTAssertEqual(loader.loadCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 2, "Expected another loading request once user initiates a load")
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 3, "Expected a third loading request once user initiates another load")
	}
	
	func test_loadingCommentsIndicator_whileLoadingComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show the loading indicator when view did load and loader hasn't complete loading yet")

		loader.completeLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected not to show the loading indicator after the loader did finish loading")

		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show the loading indicator when the user initiates a reload")

		loader.completeLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected not to show the loading indicator after loading completed with an error")
	}
	
	// MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, locale: Locale = .current, file: StaticString = #filePath, line: UInt = #line) -> (sut: CommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = CommentUIComposer.commentsComposedWith(loader: loader.loadPublisher, currentDate: currentDate, locale: locale)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Comments"
		let bundle = Bundle(for: CommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	class LoaderSpy: CommentLoader {
		
		// MARK: - CommentLoader
		
		private var completions = [(CommentLoader.Result) -> Void]()
		var cancelCount = 0

		var loadCount: Int {
			return completions.count
		}

		private class Task: CommentsLoaderTask {
			let onCancel: () -> Void

			init(onCancel: @escaping () -> Void) {
				self.onCancel = onCancel
			}

			func cancel() {
				onCancel()
			}
		}

		func load(completion: @escaping (CommentLoader.Result) -> Void) -> CommentsLoaderTask {
			completions.append(completion)
			return Task { [weak self] in
				self?.cancelCount += 1
			}
		}

		func completeLoading(with comments: [Comment] = [], at index: Int = 0) {
			completions[index](.success(comments))
		}

		func completeLoadingWithError(at index: Int = 0) {
			completions[index](.failure(NSError(domain: "loading error", code: 0)))
		}
	}
}

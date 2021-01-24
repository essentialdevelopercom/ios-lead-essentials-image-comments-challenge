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
	}
	
	// MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, locale: Locale = .current, file: StaticString = #filePath, line: UInt = #line) -> (sut: CommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = CommentUIComposer.commentsComposedWith(loader: loader.loadPublisher, currentDate: currentDate, locale: locale)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
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



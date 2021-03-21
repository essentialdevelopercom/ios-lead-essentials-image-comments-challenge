//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ángel Vázquez on 20/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import XCTest
import UIKit

class ImageCommentsViewControllerTests: XCTestCase {
	func test_loadCommentsActions_requestsLoadingCommentsFromURL() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		XCTAssertTrue(loader.requestedURLs.isEmpty, "Expected no loading requests upon creation")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.requestedURLs, [url], "Expected a single loading request when view has loaded")
		
		sut.simulateUserInitiatedReloading()
		XCTAssertEqual(loader.requestedURLs, [url, url], "Expected a second loading request once user initiates a reload")
		
		sut.simulateUserInitiatedReloading()
		XCTAssertEqual(loader.requestedURLs, [url, url, url], "Expected a third loading request once user initiates another reload")
	}
	
	func test_loadingSpinner_isVisibleWhileLoadingComments() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingSpinner, "Expected loading spinner to be shown when view has loaded")
		
		loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingSpinner, "Expected loading spinner to stop animating upon loader completion")
		
		sut.simulateUserInitiatedReloading()
		XCTAssertTrue(sut.isShowingLoadingSpinner, "Expected loading spinner to start animating once user requests a reload")
		
		loader.completeCommentsLoading(at: 1)
		XCTAssertFalse(sut.isShowingLoadingSpinner, "Expected loading spinner to stop animating upon loader completion")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsViewController(url: url, loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	class LoaderSpy: ImageCommentLoader {
		private var messages = [(url: URL, completion: (ImageCommentLoader.Result) -> Void)]()
		
		private var completions: [(ImageCommentLoader.Result) -> Void] {
			messages.map { $0.completion }
		}
		
		var requestedURLs: [URL] {
			messages.map { $0.url }
		}
		
		struct Task: ImageCommentLoaderTask {
			func cancel() { }
		}
		
		func load(from url: URL, completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderTask {
			messages.append((url, completion))
			return Task()
		}
		
		func completeCommentsLoading(at index: Int = 0) {
			completions[index](.success([]))
		}
	}
}

extension ImageCommentsViewController {
	var isShowingLoadingSpinner: Bool {
		refreshControl?.isRefreshing == true
	}
	
	func simulateUserInitiatedReloading() {
		refreshControl?.simulatePullToRefresh()
	}
}

extension UIControl {
	func simulate(event: UIControl.Event) {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: event)?.forEach {
				(target as NSObject).perform(Selector($0))
			}
		}
	}
}

extension UIRefreshControl {
	func simulatePullToRefresh() {
		simulate(event: .valueChanged)
	}
}


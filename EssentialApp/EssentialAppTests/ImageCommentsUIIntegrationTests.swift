//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Eric Garlock on 3/10/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsViewController : UITableViewController {
	
	public var loader: ImageCommentLoader?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
		
		refresh()
	}
	
	@objc public func refresh() {
		refreshControl?.beginRefreshing()
		loader?.load { [weak self] result in
			switch result {
			case .success:
				self?.refreshControl?.endRefreshing()
				break
			case .failure:
				self?.refreshControl?.endRefreshing()
				break
			}
		}
	}
}

class ImageCommentsUIComposer {
	
	static func imageCommentsComposedWith(loader: ImageCommentLoader) -> ImageCommentsViewController {
		let viewController = ImageCommentsViewController()
		viewController.title = ImageCommentPresenter.title
		viewController.loader = loader
		return viewController
	}
	
}

class ImageCommentsUIIntegrationTests: XCTestCase {

	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		XCTAssertEqual(sut.title, localized("COMMENT_VIEW_TITLE"))
	}
	
	func test_loadImageCommentActions_requestImageCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCallCount, 0)
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1)
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCallCount, 2)
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCallCount, 3)
	}
	
	func test_loadImageCommentIndicator_isVisibleWhileLoading() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeImageCommentLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
		
		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeImageCommentLoadingWithError(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
	}
	
	// MARK: - Helpers
	private func makeSUT() -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader)
		return (sut, loader)
	}
	
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class LoaderSpy: ImageCommentLoader {
		
		var completions = [(ImageCommentLoader.Result) -> Void]()
		
		var loadCallCount: Int {
			return completions.count
		}
		
		private struct TaskSpy: ImageCommentLoaderDataTask {
			func cancel() {
				
			}
		}
		
		func load(completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderDataTask {
			completions.append(completion)
			return TaskSpy()
		}
		
		func completeImageCommentLoading(at index: Int = 0) {
			completions[index](.success([]))
		}
		
		func completeImageCommentLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "error", code: 0)
			completions[index](.failure(error))
		}
		
	}

}

extension ImageCommentsViewController {
	
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
}

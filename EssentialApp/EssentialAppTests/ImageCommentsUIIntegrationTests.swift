//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Cronay on 22.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class ImageCommentUIComposer {

	private init() {}

	static func makeUI(loader: ImageCommentsLoader) -> ImageCommentsViewController {
		let controller = ImageCommentsViewController()
		controller.title = ImageCommentsPresenter.title
		controller.loader = loader
		return controller
	}
}

class ImageCommentsViewController: UITableViewController {

	var loader: ImageCommentsLoader?

	override func viewDidLoad() {
		refreshControl = UIRefreshControl()
		refreshControl?.endRefreshing()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

		refresh()
	}

	@objc private func refresh() {
		refreshControl?.beginRefreshing()
		_ = loader?.load { [weak self] _ in
			self?.refreshControl?.endRefreshing()
		}
	}
}

class ImageCommentsUIIntegrationTests: XCTestCase {

	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}

	func test_loadImageCommentsAction_requestsCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCount, 0)

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCount, 1)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 2)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 3)
	}

	func test_loadingCommentsIndicator_whileLoadingComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator)

		loader.completeLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator)

		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator)

		loader.completeLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentUIComposer.makeUI(loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}

	private class LoaderSpy: ImageCommentsLoader {

		var completions = [(ImageCommentsLoader.Result) -> Void]()

		var loadCount: Int {
			return completions.count
		}

		private class Task: ImageCommentsLoaderTask {
			func cancel() {}
		}

		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
			completions.append(completion)
			return Task()
		}

		func completeLoading(at index: Int = 0) {
			completions[index](.success([]))
		}

		func completeLoadingWithError(at index: Int = 0) {
			completions[index](.failure(NSError(domain: "loading error", code: 0)))
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

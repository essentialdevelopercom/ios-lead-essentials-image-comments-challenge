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
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

		_ = loader?.load { _ in }
	}

	@objc private func refresh() {
		_ = loader?.load { _ in }
	}
}

class ImageCommentsUIIntegrationTests: XCTestCase {

	func test_imageCommentsView_hasTitle() {
		let loader = LoaderSpy()
		let sut = ImageCommentUIComposer.makeUI(loader: loader)

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}

	func test_loadImageCommentsAction_requestsCommentsFromLoader() {
		let loader = LoaderSpy()
		let sut = ImageCommentUIComposer.makeUI(loader: loader)
		XCTAssertEqual(loader.loadCount, 0)

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCount, 1)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 2)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 3)
	}

	// MARK: - Helpers

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
		var loadCount = 0

		private class Task: ImageCommentsLoaderTask {
			func cancel() {}
		}

		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
			loadCount += 1
			return Task()
		}
	}
}

extension ImageCommentsViewController {
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
}

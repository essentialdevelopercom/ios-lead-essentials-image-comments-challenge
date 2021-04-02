//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed

final class ImageCommentsViewController: UITableViewController {
	private var loader: ImageCommentsLoader?

	convenience init(loader: ImageCommentsLoader) {
		self.init()
		self.loader = loader
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		load()
	}

	@objc private func load() {
		refreshControl?.beginRefreshing()
		loader?.load { [weak self] _ in
			self?.refreshControl?.endRefreshing()
		}
	}
}

final class ImageCommentsViewControllerTests: XCTestCase {

	func test_loadImageCommentsActions_requestImageCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")

		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a load")

		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
	}

	func test_loadingImageCommentsIndicator_isVisibleWhileLoadingImageComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")

		loader.completeImageCommentsLoading(at: 0)
		XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading is completed")

		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user initiates a reload")

		loader.completeImageCommentsLoading(at: 1)
		XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once user initiated loading is completed")
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsViewController(loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	class LoaderSpy: ImageCommentsLoader {
		private var completions = [(ImageCommentsLoader.Result) -> Void]()
		var loadCallCount: Int {
			completions.count
		}

		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) {
			completions.append(completion)
		}

		func completeImageCommentsLoading(at index: Int) {
			completions[index](.success([]))
		}
	}

}

private extension ImageCommentsViewController {
	var isShowingLoadingIndicator: Bool {
		refreshControl?.isRefreshing == true
	}

	func simulateUserInitiatedImageCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
}

private extension UIRefreshControl {
	func simulatePullToRefresh() {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
				(target as NSObject).perform(Selector($0))
			}
		}
	}
}

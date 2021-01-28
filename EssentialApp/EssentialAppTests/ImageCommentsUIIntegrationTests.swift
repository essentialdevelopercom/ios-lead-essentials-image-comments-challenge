//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Lukas Bahrle Santana on 27/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed

class ImageCommentsViewController: UITableViewController{
	var loader: ImageCommentsLoader?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
		
		refresh()
	}
	
	@objc private func refresh() {
		loader?.load{_ in}
	}
}

class ImageCommentsUIComposer{
	static func imageComments() -> ImageCommentsViewController{
		let controller = ImageCommentsViewController()
		controller.title = ImageCommentsPresenter.title
		return controller
	}
}

final class ImageCommentsUIIntegrationTests: XCTestCase {
	func test_imageCommentsView_hasTitle() {
		let (sut,_) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadFeedActions_requestImageCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadImageComentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadImageComentsCallCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(loader.loadImageComentsCallCount, 2, "Expected another loading request once user initiates a reload")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (ImageCommentsViewController, LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageComments()
		sut.loader = loader
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
}


extension ImageCommentsUIIntegrationTests{
	class LoaderSpy: ImageCommentsLoader{
		
		private var imageCommentsRequests = [(ImageCommentsLoader.Result) -> Void]()
		
		var loadImageComentsCallCount: Int {
			return imageCommentsRequests.count
		}
		
		private struct TaskSpy: ImageCommentsLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}
		
		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
			imageCommentsRequests.append(completion)
			return TaskSpy{}
		}
		
		
	}
}


extension ImageCommentsViewController {
	func simulateUserInitiatedImageCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
}

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
		
		loader?.load { _ in }
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
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1)
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
		
		var loadCallCount: Int = 0
		
		private struct TaskSpy: ImageCommentLoaderDataTask {
			func cancel() {
				
			}
		}
		
		func load(completion: @escaping (Result<[ImageComment], Error>) -> Void) -> ImageCommentLoaderDataTask {
			loadCallCount += 1
			return TaskSpy()
		}
		
	}

}

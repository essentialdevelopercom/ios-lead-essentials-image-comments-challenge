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
				break
			case .failure:
				break
			}
			self?.refreshControl?.endRefreshing()
		}
	}
}

class ImageCommentCell: UITableViewCell {
	let message = UILabel()
	let created = UILabel()
	let username = UILabel()
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
	
	func test_loadImageCommentCompletion_rendersSuccessfullyLoadedImageComments() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
	}
	
	// MARK: - Helpers
	private func makeSUT() -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader)
		return (sut, loader)
	}
	
	func assertThat(_ sut: ImageCommentsViewController, isRendering imageComments: [ImageCommentViewModel], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		guard sut.numberOfRenderedImageCommentViews() == imageComments.count else {
			return XCTFail("Expected \(imageComments.count) image comments, got \(sut.numberOfRenderedImageCommentViews()) instead.", file: file, line: line)
		}
		
		imageComments.enumerated().forEach { index, imageComment in
			assertThat(sut, hasViewConfiguredFor: imageComment, at: index, file: file, line: line)
		}
		
		executeRunLoopToCleanUpReferences()
	}
	
	func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor imageComment: ImageCommentViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.messageText, imageComment.message, "for view at index (\(index))", file: file, line: line)
		XCTAssertEqual(cell.createdText, imageComment.created, "for view at index (\(index))", file: file, line: line)
		XCTAssertEqual(cell.usernameText, imageComment.username, "for view at index (\(index))", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
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
	
	func numberOfRenderedImageCommentViews() -> Int {
		return tableView.numberOfRows(inSection: imageCommentsSection)
	}
	
	func imageCommentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedImageCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: imageCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	var imageCommentsSection: Int {
		return 0
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
}

extension ImageCommentCell {
	var messageText: String? { return message.text }
	var createdText: String? { return created.text }
	var usernameText: String? { return username.text }
}

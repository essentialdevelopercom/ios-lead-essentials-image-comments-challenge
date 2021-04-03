//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsUIIntegrationTests: XCTestCase {

	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_TITLE"))
	}

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
		XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading is completed successfully")

		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user initiates a reload")

		loader.completeImageCommentsLoadingWithError(at: 1)
		XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once user initiated loading completed with error")
	}

	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedImageComments() {
		let imageComment0 = makeImageComment(message: "a message", authorName: "a user", createdAt: Date())
		let imageComment1 = makeImageComment(message: "another message", authorName: "another user", createdAt: Date())
		let imageComment2 = makeImageComment(message: "yet another message", authorName: "yet another user", createdAt: Date())
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])

		loader.completeImageCommentsLoading(with: [imageComment0], at: 0)
		assertThat(sut, isRendering: [imageComment0])

		sut.simulateUserInitiatedImageCommentsReload()
		loader.completeImageCommentsLoading(with: [imageComment0, imageComment1, imageComment2], at: 1)
		assertThat(sut, isRendering: [imageComment0, imageComment1, imageComment2])
	}

	func test_loadImageCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let imageComment0 = makeImageComment(message: "a message", authorName: "a user", createdAt: Date())
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [imageComment0], at: 0)
		assertThat(sut, isRendering: [imageComment0])

		sut.simulateUserInitiatedImageCommentsReload()
		loader.completeImageCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [imageComment0])
	}

	func test_imageCommentsView_doesNotRenderImageCommentWhenNoLongerVisible() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [makeImageComment()])

		let view = sut.simulateImageCommentNotVisible(at: 0)

		XCTAssertNil(view?.messageText, "Expected no rendered message text when the view is no longer visible")
		XCTAssertNil(view?.authorNameText, "Expected no rendered author name text when the view is no longer visible")
		XCTAssertNil(view?.createdAtText, "Expected no rendered created at text when the view is no longer visible")
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(imageCommentsLoader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	private func assertThat(_ sut: ImageCommentsViewController, isRendering imageComments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
		guard sut.numberOfRenderedImageCommentViews() == imageComments.count else {
			return XCTFail("Expected \(imageComments.count) image comments, got \(sut.numberOfRenderedImageCommentViews()) instead.", file: file, line: line)
		}

		imageComments.enumerated().forEach { index, imageComment in
			assertThat(sut, hasViewConfiguredFor: imageComment, at: index, file: file, line: line)
		}
	}

	private func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor imageComment: ImageComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)

		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.messageText, imageComment.message, "Expected message to be \(imageComment.message) for image comment view at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.authorNameText, imageComment.author.username, "Expected author to be \(imageComment.author) for image comment view at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.createdAtText, dateFormatter.string(from: imageComment.createdAt), "Expected created at to be \(dateFormatter.string(from: imageComment.createdAt)) for image comment view at index \(index)", file: file, line: line)
	}

	private var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		df.timeStyle = .medium
		return df
	}()

	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}

	private func makeImageComment(message: String = "a message", authorName: String = "a user", createdAt: Date = Date()) -> ImageComment {
		ImageComment(id: UUID(), message: message, createdAt: createdAt, author: ImageCommentAuthor(username: authorName))
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

		func completeImageCommentsLoading(with imageComments: [ImageComment] = [], at index: Int = 0) {
			completions[index](.success(imageComments))
		}

		func completeImageCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			completions[index](.failure(error))
		}
	}

}

private extension ImageCommentsViewController {
	var isShowingLoadingIndicator: Bool {
		refreshControl?.isRefreshing == true
	}

	private var imageCommentsSection: Int {
		return 0
	}

	func simulateUserInitiatedImageCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}

	func numberOfRenderedImageCommentViews() -> Int {
		tableView.numberOfRows(inSection: imageCommentsSection)
	}

	@discardableResult
	func simulateImageCommentViewVisible(at index: Int) -> ImageCommentCell? {
		imageCommentView(at: index) as? ImageCommentCell
	}

	@discardableResult
	func simulateImageCommentNotVisible(at row: Int) -> ImageCommentCell? {
		let view = simulateImageCommentViewVisible(at: row)

		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: imageCommentsSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

		return view
	}

	func imageCommentView(at row: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: imageCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
}

private extension ImageCommentCell {
	var messageText: String? {
		messageLabel.text
	}

	var authorNameText: String? {
		authorNameLabel.text
	}

	var createdAtText: String? {
		createdAtLabel.text
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

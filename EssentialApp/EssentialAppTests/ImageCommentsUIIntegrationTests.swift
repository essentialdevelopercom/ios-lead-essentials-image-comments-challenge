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

class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView{
	
	var loader: ImageCommentsLoader?
	var presenter: ImageCommentsPresenter?
	
	private var imageComments = [PresentableImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
		
		tableView.register(ImageCommentCell.self, forCellReuseIdentifier: "ImageComment")
		
		refresh()
	}
	
	@objc private func refresh() {
		self.refreshControl?.beginRefreshing()
		loader?.load{ [weak self] result in
			self?.refreshControl?.endRefreshing()
			
			switch result{
			case .success(let comments):
				self?.presenter?.didFinishLoadingImageComments(with: comments)
			case .failure(_):
				break
			}
		}
	}
	
	func display(_ viewModel: ImageCommentsViewModel) {
		imageComments = viewModel.imageComments
	}
	
	func display(_ viewModel: ImageCommentsLoadingViewModel) {
		
	}
	
	func display(_ viewModel: ImageCommentsErrorViewModel) {
		
	}
	
	// MARK: - Table View
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return imageComments.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ImageComment", for: indexPath) as! ImageCommentCell
		cell.configure(imageComment: imageComments[indexPath.row])
		
		return cell
	}
}

class ImageCommentCell: UITableViewCell{
	let message = UILabel()
	let createdAt = UILabel()
	let username = UILabel()
	
	
	func configure(imageComment: PresentableImageComment){
		message.text = imageComment.message
		createdAt.text = imageComment.createdAt
		username.text = imageComment.username
	}
}

class ImageCommentsUIComposer{
	static func imageComments() -> ImageCommentsViewController{
		let controller = ImageCommentsViewController()
		controller.title = ImageCommentsPresenter.title
		
		let presenter = ImageCommentsPresenter(imageCommentsView: WeakRefVirtualProxy(controller), loadingView: WeakRefVirtualProxy(controller), errorView: WeakRefVirtualProxy(controller))
		
		controller.presenter = presenter
		
		
		return controller
	}
}

final class ImageCommentsUIIntegrationTests: XCTestCase {
	func test_imageCommentsView_hasTitle() {
		let (sut,_) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadImageCommentsActions_requestImageCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadImageComentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadImageComentsCallCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(loader.loadImageComentsCallCount, 2, "Expected another loading request once user initiates a reload")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(loader.loadImageComentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}
	
	func test_loadingImageCommentsIndicator_isVisibleWhileLoadingImageComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeImageCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeImageCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
		
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedImageComments() {
		let (sut, loader) = makeSUT()
		let currentDate = Date()
		let (comment0, presentable0) = makeImageComment(message: "message0", username: "username0", createdAt: (currentDate.adding(days: -1), "1 day ago"))
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeImageCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [presentable0])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (ImageCommentsViewController, LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageComments()
		
		sut.loader = loader
		
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeImageComment(message: String, username: String, createdAt: (date: Date, presentable: String)) -> (ImageComment, PresentableImageComment) {
		
		let imageComment = ImageComment(id: UUID(), message: message, createdAt: createdAt.date, author: ImageCommentAuthor(username: username))
		
		let presentableImageComment = PresentableImageComment(message: message, createdAt: createdAt.presentable, username: username)
		
		return (imageComment, presentableImageComment)
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
		
		func completeImageCommentsLoading(with imageComments: [ImageComment] = [], at index: Int = 0) {
			imageCommentsRequests[index](.success(imageComments))
		}
		
		func completeImageCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			imageCommentsRequests[index](.failure(error))
		}
		
		
		
	}
}


extension ImageCommentsViewController {
	func simulateUserInitiatedImageCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
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
	
	private var imageCommentsSection: Int {
		return 0
	}
	
	
}



extension ImageCommentsUIIntegrationTests {
	
	func assertThat(_ sut: ImageCommentsViewController, isRendering imageComments: [PresentableImageComment], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		guard sut.numberOfRenderedImageCommentViews() == imageComments.count else {
			return XCTFail("Expected \(imageComments.count) image comments, got \(sut.numberOfRenderedImageCommentViews()) instead.", file: file, line: line)
		}
		
		imageComments.enumerated().forEach { index, image in
			assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
		}
		
		executeRunLoopToCleanUpReferences()
	}
	
	func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor imageComment: PresentableImageComment, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.messageText, imageComment.message, "Expected message to be \(imageComment.message) for image comment view at index (\(index))", file: file, line: line)
		
		XCTAssertEqual(cell.createdAtText, imageComment.createdAt, "Expected date to be \(imageComment.createdAt) for image comment view at index (\(index))", file: file, line: line)
		
		XCTAssertEqual(cell.usernameText, imageComment.username, "Expected username to be \(imageComment.createdAt) for image comment view at index (\(index))", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
}


extension ImageCommentCell{
	var messageText: String?{ message.text }
	var createdAtText: String?{ createdAt.text }
	var usernameText: String?{ username.text }
}



private extension Date {
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
	
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}



// MARK: - WeakRefVirtualProxy

final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?

	init(_ object: T) {
		self.object = object
	}
 }

 extension WeakRefVirtualProxy: ImageCommentsErrorView where T: ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel) {
		object?.display(viewModel)
	}
 }

 extension WeakRefVirtualProxy: ImageCommentsLoadingView where T: ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel) {
		object?.display(viewModel)
	}
 }

 extension WeakRefVirtualProxy: ImageCommentsView where T: ImageCommentsView {
	func display(_ model: ImageCommentsViewModel) {
		object?.display(model)
	}
 }

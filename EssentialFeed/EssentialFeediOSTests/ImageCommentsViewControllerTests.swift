//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Alok Subedi on 04/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed

class ImageCommentsCell: UITableViewCell {
	var usernameLabel = UILabel()
	var createdTimeLabel = UILabel()
	var message = UILabel()
}

protocol ImageCommentsViewControllerDelegate {
	func didRequestImageCommentsRefresh()
}

class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView {
	private var delegate: ImageCommentsViewControllerDelegate?
	private var imageComments = [ImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	convenience init(delegate: ImageCommentsViewControllerDelegate) {
		self.init()
		self.delegate = delegate
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		
		load()
	}
	
	@objc func load() {
		delegate?.didRequestImageCommentsRefresh()
	}
	
	func display(_ viewModel: ImageCommentsViewModel) {
		self.refreshControl?.endRefreshing()
		self.imageComments = viewModel.comments
	}
	
	func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading {
			self.refreshControl?.beginRefreshing()
		} else {
			self.refreshControl?.endRefreshing()
		}
	}
	
	func display(_ viewModel: ImageCommentsErrorViewModel) {
		if viewModel.message != nil {
			self.refreshControl?.endRefreshing()
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return imageComments.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = imageComments[indexPath.row]
		let cell = ImageCommentsCell()
		cell.usernameLabel.text = model.author.username
		cell.createdTimeLabel.text = relativeDateStringFromNow(to: model.createdDate)
		cell.message.text = model.message
		
		return cell
	}
	
	private func relativeDateStringFromNow(to date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDateString = formatter.localizedString(for: date, relativeTo: Date())
		return relativeDateString
	}
}

class ImageCommentsUIComposer {
	static func imageCommentsComposedWith(loader: ImageCommentsLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(loader: loader)
		
		let imageCommentsViewController = ImageCommentsViewController(delegate: presentationAdapter)
		
		presentationAdapter.presenter = ImageCommentsPresenter(
			imageCommentsView: WeakRefVirtualProxy(imageCommentsViewController),
			loadingView: WeakRefVirtualProxy(imageCommentsViewController),
			errorView: WeakRefVirtualProxy(imageCommentsViewController)
		)
		
		return imageCommentsViewController
	}
}

class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	private let loader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	
	init(loader: ImageCommentsLoader) {
		self.loader = loader
	}
	
	func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingImageComments()
		loader.load { [weak self] result in
			switch result {
			case let .success(imageComments):
				self?.presenter?.didFinishLoadingImageComments(with: imageComments)
				
			case let .failure(error):
				self?.presenter?.didFinishLoadingImageComments(with: error)
			}
		}
	}
}

class WeakRefVirtualProxy<T: AnyObject> {
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
	func display(_ viewModel: ImageCommentsViewModel) {
		object?.display(viewModel)
	}
}


class ImageCommentsViewControllerTests: XCTestCase {

	func test_init_doesNotRequestLoadImageComments() {
		let (_, loader) = makeSUT()
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	func test_loadImmageCommentsAction_requestsToLoadImageComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1)
		
		sut.refreshControl?.simulatePullToRefresh()
		XCTAssertEqual(loader.loadCallCount, 2)
		
		sut.refreshControl?.simulatePullToRefresh()
		XCTAssertEqual(loader.loadCallCount, 3)
	}
	
	func test_loadingIndicator_isVisibleWhileLoadingImageComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator)
		
		loader.completeLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator)
		
		sut.refreshControl?.simulatePullToRefresh()
		XCTAssertTrue(sut.isShowingLoadingIndicator)
		
		loader.completeLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator)
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedImageComments() {
		let imageComment0 = makeComment(id: UUID(), message: "message", created_at: Date(), username: "user")
		let imageComment1 = makeComment(id: UUID(), message: "another message", created_at: Date(), username: "another user")
		let imageComment2 = makeComment(id: UUID(), message: "third message", created_at: Date(), username: "third user")
		let imageComment3 = makeComment(id: UUID(), message: "fourth message", created_at: Date(), username: "fourth user")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeLoading(with: [imageComment0], at: 0)
		assertThat(sut, isRendering: [imageComment0])
		
		sut.refreshControl?.simulatePullToRefresh()
		loader.completeLoading(with: [imageComment0, imageComment1, imageComment2, imageComment3], at: 1)
		assertThat(sut, isRendering: [imageComment0, imageComment1, imageComment2, imageComment3])
	}
	
	//MARK: Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		
		return (sut, loader)
	}
	
	private func makeComment(id: UUID, message: String, created_at: Date, username: String) -> ImageComment {
		let author = CommentAuthor(username: username)
		let comment = ImageComment(id: id, message: message, createdDate: created_at, author: author)
		
		return comment
	}
	
	private func relativeDateStringFromNow(to date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDateString = formatter.localizedString(for: date, relativeTo: Date())
		return relativeDateString
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, isRendering imageComments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
		XCTAssertEqual(sut.numberOfRenderedImageCommentsViews, imageComments.count, file: file, line: line)
		
		imageComments.enumerated().forEach { index, comment in
			let cell = sut.renderedCell(at: index)
			XCTAssertEqual(cell?.usernameText, comment.author.username, file: file, line: line)
			XCTAssertEqual(cell?.createdTimetext, relativeDateStringFromNow(to: comment.createdDate), file: file, line: line)
			XCTAssertEqual(cell?.messageText, comment.message, file: file, line: line)
		}
	}
	
	class LoaderSpy: ImageCommentsLoader {
		private var imageCommentsRequests = [(ImageCommentsLoader.Result) -> Void]()
		var loadCallCount: Int {
			return imageCommentsRequests.count
		}
		
		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) {
			imageCommentsRequests.append((completion))
		}
		
		func completeLoading(with comments: [ImageComment] = [], at index: Int) {
			imageCommentsRequests[index](.success(comments))
		}
		
		func completeLoadingWithError(at index: Int) {
			imageCommentsRequests[index](.failure(NSError()))
		}
	}
}

private extension ImageCommentsViewController {
	func renderedCell(at row: Int) -> ImageCommentsCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: imageCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentsCell
	}
	
	var isShowingLoadingIndicator: Bool {
		return self.refreshControl?.isRefreshing == true
	}
	
	var numberOfRenderedImageCommentsViews: Int {
		return tableView.numberOfRows(inSection: imageCommentsSection)
	}
	
	private var imageCommentsSection: Int { 0 }
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

private extension ImageCommentsCell {
	var usernameText: String? {
		return usernameLabel.text
	}
	
	var messageText: String? {
		return message.text
	}
	
	var createdTimetext: String? {
		return createdTimeLabel.text
	}
}

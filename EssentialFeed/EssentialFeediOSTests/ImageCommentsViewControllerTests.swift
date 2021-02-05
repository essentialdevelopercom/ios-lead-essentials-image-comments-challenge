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

protocol ImageCommentsViewControllerDelegate {
	func didRequestImageCommentsRefresh()
}

class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView {
	private var delegate: ImageCommentsViewControllerDelegate?
	
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
	
	//MARK: Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		
		return (sut, loader)
	}
	
	class LoaderSpy: ImageCommentsLoader {
		private var imageCommentsRequests = [(ImageCommentsLoader.Result) -> Void]()
		var loadCallCount: Int {
			return imageCommentsRequests.count
		}
		
		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) {
			imageCommentsRequests.append((completion))
		}
		
		func completeLoading(at index: Int) {
			imageCommentsRequests[index](.success([]))
		}
		
		func completeLoadingWithError(at index: Int) {
			imageCommentsRequests[index](.failure(NSError()))
		}
	}
}

private extension ImageCommentsViewController {
	var isShowingLoadingIndicator: Bool {
		return self.refreshControl?.isRefreshing == true
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

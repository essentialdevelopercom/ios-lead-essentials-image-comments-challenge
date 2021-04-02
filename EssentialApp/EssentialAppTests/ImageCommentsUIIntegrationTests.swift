//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Bogdan Poplauschi on 02/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import XCTest

class ImageCommentsLoaderPresentationAdapter: ImageCommentsViewControllerDelegate {
	let loader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	
	init(loader: ImageCommentsLoader) {
		self.loader = loader
	}
	
	func didRequestCommentsRefresh() {
		presenter?.didStartLoadingComments()
		
		loader.load { result in
			switch result {
			case let .success(comments):
				self.presenter?.didFinishLoading(with: comments)
				
			default:
				break
			}
		}
	}
}

class ImageCommentsUIComposer {
	static func imageCommentsComposedWith(commentsLoader: ImageCommentsLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsLoaderPresentationAdapter(loader: commentsLoader)
		
		let imageCommentsController = makeImageCommentsViewController(delegate: presentationAdapter)
		
		presentationAdapter.presenter = ImageCommentsPresenter(
			imageCommentsView: imageCommentsController,
			loadingView: imageCommentsController,
			errorView: imageCommentsController)
		
		return imageCommentsController
	}
	
	private static func makeImageCommentsViewController(delegate: ImageCommentsViewControllerDelegate) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let commentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		commentsController.delegate = delegate
		return commentsController
	}
}

final class ImageCommentsUIIntegrationTests: XCTestCase {
	
	func test_loadCommentsActions_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 2, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}
	
	func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeCommentsLoading()
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(commentsLoader: loader)
		return (sut, loader)
	}
	
	private class LoaderSpy: ImageCommentsLoader {
		
		private struct TaskSpy: ImageCommentsLoaderTask {
			func cancel() {}
		}
		
		private var imageCommentsRequests = [(ImageCommentsLoader.Result) -> Void]()
		
		var loadImageCommentsCallCount: Int {
			return imageCommentsRequests.count
		}
		
		func completeCommentsLoading(at index: Int = 0) {
			imageCommentsRequests[index](.success([]))
		}
		
		@discardableResult
		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
			imageCommentsRequests.append(completion)
			return TaskSpy()
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
}

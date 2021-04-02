//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Bogdan Poplauschi on 02/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp // TODO: remove @testable once we move the code to prod
import XCTest

class ImageCommentsLoaderPresentationAdapter: ImageCommentsViewControllerDelegate {
	let loader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	
	init(loader: ImageCommentsLoader) {
		self.loader = loader
	}
	
	func didRequestCommentsRefresh() {
		presenter?.didStartLoadingComments()
		
		loader.load { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case let .success(comments):
				self.presenter?.didFinishLoading(with: comments)
				
			case let .failure(error):
				self.presenter?.didFinishLoading(with: error)
			}
		}
	}
}

class ImageCommentsUIComposer {
	static func imageCommentsComposedWith(commentsLoader: ImageCommentsLoader, date: Date = Date()) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsLoaderPresentationAdapter(loader: commentsLoader)
		
		let imageCommentsController = makeImageCommentsViewController(delegate: presentationAdapter)
		
		presentationAdapter.presenter = ImageCommentsPresenter(
			imageCommentsView: WeakRefVirtualProxy(imageCommentsController),
			loadingView: WeakRefVirtualProxy(imageCommentsController),
			errorView: WeakRefVirtualProxy(imageCommentsController),
			currentDate: date)
		
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
		
		loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	}
	
	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let fixedDate = anyDate()
		let imageComments = uniqueComments(currentDate: fixedDate)
		let (sut, loader) = makeSUT(date: fixedDate)
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: imageComments.comments)
		
		for (index, presentableImageComment) in imageComments.presentableComments.enumerated() {
			let cell = sut.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ImageCommentCell
			XCTAssertEqual(cell?.usernameLabel?.text, presentableImageComment.author)
			XCTAssertEqual(cell?.createdAtLabel?.text, presentableImageComment.createdAt)
			XCTAssertEqual(cell?.commentLabel?.text, presentableImageComment.message)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(date: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(commentsLoader: loader, date: date)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func uniqueComments(currentDate: Date) -> (comments: [ImageComment], presentableComments: [PresentableImageComment]) {
		let comments = [
			ImageComment(
				id: UUID(),
				message: "a message",
				createdAt: Date(timeIntervalSinceReferenceDate: currentDate.timeIntervalSinceReferenceDate - 60 * 60 * 24),
				author: ImageCommentAuthor(username: "a username")
			),
			ImageComment(
				id: UUID(),
				message: "another message",
				createdAt: Date(timeIntervalSinceReferenceDate: currentDate.timeIntervalSinceReferenceDate - 60 * 60),
				author: ImageCommentAuthor(username: "another username")
			),
		]
		
		let presentableComments = [
			PresentableImageComment(createdAt: "1 day ago", message: comments[0].message, author: comments[0].author.username),
			PresentableImageComment(createdAt: "1 hour ago", message: comments[1].message, author: comments[1].author.username)
		]
		
		return (comments, presentableComments)
	}
	
	private func anyDate() -> Date {
		return Date(timeIntervalSinceReferenceDate: 638556190)
	}
	
	private class LoaderSpy: ImageCommentsLoader {
		
		private struct TaskSpy: ImageCommentsLoaderTask {
			func cancel() {}
		}
		
		private var imageCommentsRequests = [(ImageCommentsLoader.Result) -> Void]()
		
		var loadImageCommentsCallCount: Int {
			return imageCommentsRequests.count
		}
		
		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			imageCommentsRequests[index](.success(comments))
		}
		
		func completeCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			imageCommentsRequests[index](.failure(error))
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

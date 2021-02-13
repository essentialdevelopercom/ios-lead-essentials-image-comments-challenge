//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class CommentsUIIntegrationTests: XCTestCase {
	
	func test_commentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadCommentActions_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		
		XCTAssertEqual(loader.loadCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 2, "Expected another loading request once user initiates a load")
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 3, "Expected a third loading request once user initiates another load")
	}
	
	func test_loadingCommentsIndicator_whileLoadingComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show the loading indicator when view did load and loader hasn't complete loading yet")

		loader.completeLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected not to show the loading indicator after the loader did finish loading")

		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show the loading indicator when the user initiates a reload")

		loader.completeLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected not to show the loading indicator after loading completed with an error")
	}
	
	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let date = Date()
		let comment0 = makeComment(id: UUID(), message: "message0", date: (date: date.adding(days: -1), string: "1 day ago"), author: "author0")
		let comment1 = makeComment(id: UUID(), message: "message1", date: (date: date.adding(days: -3), string: "3 days ago"), author: "author1")
		let comment2 =  makeComment(id: UUID(), message: "message2", date: (date: date.adding(days: -31), string: "1 month ago"), author: "author2")
		let comment3 = makeComment(id: UUID(), message: "message3", date: (date: date.adding(days: -366), string: "1 year ago"), author: "author3")
		let (sut, loader) = makeSUT(currentDate: { date }, locale: .init(identifier: "en_US_POSIX"))

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])

		loader.completeLoading(with: [comment0.model], at: 0)
		assertThat(sut, isRendering: [comment0.expected])

		sut.simulateUserInitiatedReload()
		loader.completeLoading(with: [comment0.model, comment1.model, comment2.model, comment3.model], at: 1)
		assertThat(sut, isRendering: [comment0.expected, comment1.expected, comment2.expected, comment3.expected])
	}
	
	func test_loadCommentsCompletion_rendersErrorMessageOnLoaderFailureUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("COMMENTS_VIEW_CONNECTION_ERROR"))

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_cancelCommentsLoading_whenViewIsDismissed() {
		let loader = LoaderSpy()
		var sut: CommentsViewController?

		autoreleasepool {
			sut = CommentUIComposer.commentsComposedWith(loader: loader.loadPublisher)
			sut?.loadViewIfNeeded()
		}

		XCTAssertEqual(loader.cancelCount, 0, "Loading should not be cancelled when view just did load")

		sut = nil
		XCTAssertEqual(loader.cancelCount, 1, "Loading should be cancelled when view is about to disappear")
	}
	
	func test_feedImageSelection_navigatesToComments() {
		let feed = launch(httpClient: .online(response), store: .empty)

		feed.simulateFeedImageSelection(at: 0)
		RunLoop.current.run(until: Date())

		let comments = feed.navigationController?.topViewController as? CommentsViewController
		XCTAssertNotNil(comments, "Expected shown view to be the image comments UI")
		XCTAssertEqual(comments?.numberOfRenderedCommentViews(), 2)

		XCTAssertNotNil(comments?.commentView(at: 0), "Expected a comment view for the first comment")
		XCTAssertEqual(comments?.commentMessage(at: 0), "some message")

		XCTAssertNotNil(comments?.commentView(at: 1), "Expected a comment view for the second comment")
		XCTAssertEqual(comments?.commentMessage(at: 1), "another message")
	}
	
	
	// MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, locale: Locale = .current, file: StaticString = #filePath, line: UInt = #line) -> (sut: CommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = CommentUIComposer.commentsComposedWith(loader: loader.loadPublisher, currentDate: currentDate, locale: locale)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func launch(
		httpClient: HTTPClientStub = .offline,
		store: InMemoryFeedStore = .empty
	) -> FeedViewController {
		let sut = SceneDelegate(httpClient: httpClient, store: store)
		sut.window = UIWindow()
		sut.configureWindow()
		
		let nav = sut.window?.rootViewController as? UINavigationController
		return nav?.topViewController as! FeedViewController
	}
	
	private func enterBackground(with store: InMemoryFeedStore) {
		let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
		sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
	}
	
	private func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeData(for: url), response)
	}
	
	private func makeData(for url: URL) -> Data {
		switch url.absoluteString {
		case "http://image.com":
			return makeImageData()

		case "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed":
			return makeFeedData()

		case "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/2C6A70A3-FA35-449C-816F-6C6F7C294393/comments":
			return makeCommentsData()

		default:
			fatalError("There's no data defined for \(url)")
		}
	}
	
	private func makeImageData() -> Data {
		return UIImage.make(withColor: .red).pngData()!
	}
	
	private func makeFeedData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": "2c6a70a3-fa35-449c-816f-6c6f7c294393", "image": "http://image.com"],
			["id": UUID().uuidString, "image": "http://image.com"]
		]])
	}

	private func makeCommentsData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": UUID().uuidString, "message": "some message", "created_at" : "2008-09-24T02:10:22+00:00", "author": ["username": "some user"]],
			["id": UUID().uuidString, "message": "another message", "created_at" : "2012-04-02T02:22:13+00:00", "author": ["username": "another user"]]
		]])
	}
	
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Comments"
		let bundle = Bundle(for: CommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	struct ExpectedCellContent {
		let username: String
		let message: String
		let date: String
	}
	

	private func makeComment(id: UUID, message: String, date: (date: Date, string: String), author: String) -> (model: Comment, expected: ExpectedCellContent) {
		return (Comment(id: id, message: message, createdAt: date.date, author: Author(username: author)), ExpectedCellContent(username: author, message: message, date: date.string))
	}
	
	class LoaderSpy: CommentLoader {
		
		// MARK: - CommentLoader
		
		private var completions = [(CommentLoader.Result) -> Void]()
		var cancelCount = 0

		var loadCount: Int {
			return completions.count
		}

		private class Task: CommentsLoaderTask {
			let onCancel: () -> Void

			init(onCancel: @escaping () -> Void) {
				self.onCancel = onCancel
			}

			func cancel() {
				onCancel()
			}
		}

		func load(completion: @escaping (CommentLoader.Result) -> Void) -> CommentsLoaderTask {
			completions.append(completion)
			return Task { [weak self] in
				//guard self != nil else { return }
				self?.cancelCount += 1
			}
		}

		func completeLoading(with comments: [Comment] = [], at index: Int = 0) {
			completions[index](.success(comments))
		}

		func completeLoadingWithError(at index: Int = 0) {
			completions[index](.failure(NSError(domain: "loading error", code: 0)))
		}
	}
}

extension Date {
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}

extension FeedViewController {
	func simulateFeedImageSelection(at row: Int) {
		tableView(tableView, didSelectRowAt: IndexPath(row: row, section: feedImagesSection))
	}
	private var feedImagesSection: Int {
		return 0
	}
}

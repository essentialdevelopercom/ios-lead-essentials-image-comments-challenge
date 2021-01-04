//
//  CommentViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Khoi Nguyen on 30/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
import EssentialFeed
import UIKit

struct PresentableComment {
	public let id: UUID
	public let message: String
	public let createAt: String
	public let author: String
}

class CommentCell: UITableViewCell {
	let authorLabel = UILabel()
	let commentLabel = UILabel()
	let timestampLabel = UILabel()
	
}

public class CommentViewController: UITableViewController {
	private var loader: CommentLoader?
	private var tableModel = [Comment]()
	
	convenience init(loader: CommentLoader) {
		self.init()
		self.loader = loader
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		load()
	}
	
	@objc private func load() {
		refreshControl?.beginRefreshing()
		
		loader?.load { [weak self] result in
			switch result {
			case let .success(comments):
				self?.tableModel = comments
				self?.tableView.reloadData()
				
			case .failure: break
			}
			self?.refreshControl?.endRefreshing()
		}
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = tableModel[indexPath.row]
		let cell = CommentCell()
		cell.authorLabel.text = model.author.username
		cell.timestampLabel.text = "any date"
		cell.commentLabel.text = model.message
		
		return cell
	}
}

class CommentViewControllerTests: XCTestCase {
	
	func test_loadCommentAction_requestsCommentFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading request before the view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1, "Expected a request once the view is loaded")
		
		sut.simulateUserInititateCommentReload()
		XCTAssertEqual(loader.loadCallCount, 2, "Expected another request once user initiates a load")
		
		sut.simulateUserInititateCommentReload()
		XCTAssertEqual(loader.loadCallCount, 3, "Expected a third request once user initiates another load")
	}
	
	func test_loadingCommentIndicator_isVisibleWhileLoadingComment() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
	
		loader.completeCommentLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
		
		sut.simulateUserInititateCommentReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user intiates a reload")
		
		loader.completeCommentLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user intitiated reload is completed")
	}
	
	func test_loadCommentCompletion_rendersSuccessfullyLoadedComment() {
		let comment0 = makeComment(message: "a messages", createAt: Date(), author: "an author")
		let comment1 = makeComment(message: "another messages", createAt: Date(), author: "another author")
		let comment2 = makeComment(message: "a third messages", createAt: Date(), author: "a third  author")
		let comment3 = makeComment(message: "a fourth messages", createAt: Date(), author: "a fourth author")
		
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeCommentLoading(with: [comment0.model])
		assertThat(sut, isRendering: [comment0.presentableModel])
		
		loader.completeCommentLoading(with: [comment0.model, comment1.model, comment2.model, comment3.model])
		assertThat(sut, isRendering: [comment0.presentableModel, comment1.presentableModel, comment2.presentableModel, comment3.presentableModel])
	}
	
	func test_loadCommentCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment0 = makeComment(message: "a messages", createAt: Date(), author: "an author")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentLoading(with: [comment0.model], at: 0)
		assertThat(sut, isRendering: [comment0.presentableModel])
		
		sut.simulateUserInititateCommentReload()
		loader.completeCommentLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment0.presentableModel])
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CommentViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = CommentViewController(loader: loader)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		
		return (sut, loader)
	}
	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}
	
	class LoaderSpy: CommentLoader {
		var loadCallCount: Int {
			return completions.count
		}
		var completions = [(CommentLoader.Result) -> Void]()
		func load(completion: @escaping (CommentLoader.Result) -> Void) {
			completions.append(completion)
		}
		
		func completeCommentLoading(with comments: [Comment] = [], at index: Int = 0) {
			completions[index](.success(comments))
		}
		
		func completeCommentLoadingWithError(at index: Int = 0) {
			completions[index](.failure(NSError(domain: "error", code: 0)))
		}
	}
	
	private func makePresentableComment(message: String, createAt: String, author: String) -> PresentableComment {
		return PresentableComment(id: UUID(), message: message, createAt: createAt, author: author)
	}
	
	private func makeComment(message: String, createAt: Date, author: String) -> (model: Comment, presentableModel: PresentableComment) {
		let id = UUID()
		let model = Comment(id: id, message: message, createAt: Date(), author: CommentAuthor(username: author))
		let presentableModel = makePresentableComment(message: message, createAt: "any date", author: author)
		return (model, presentableModel)
	}
	
	private func assertThat(_ sut: CommentViewController, isRendering comments: [PresentableComment], file: StaticString = #file, line: UInt = #line) {
		
		guard sut.numberOfRenderedComments() == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedComments()) instead", file: file, line: line)
		}
		
		comments.enumerated().forEach { index, comment in
			assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
		}
	}
	
	private func assertThat(_ sut: CommentViewController, hasViewConfiguredFor comment: PresentableComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
		let view = sut.commentView(at: index)
		guard let cell = view as? CommentCell else {
			return XCTFail("Expected to get \(CommentCell.self), got \(String(describing: view)) instead")
		}

		XCTAssertEqual(cell.authorText, comment.author, "Expected `authorText` to be \(String(describing: cell.authorText)) for cell at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.messageText, comment.message, "Expected `messageText` to be \(String(describing: cell.messageText)) for cell at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.timestampText, comment.createAt, "Expected `timestampText` to be \(String(describing: cell.timestampText)) for cell at index \(index)", file: file, line: line)
	}
}

private extension CommentViewController {
	func simulateUserInititateCommentReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	func numberOfRenderedComments() -> Int {
		return tableView.numberOfRows(inSection: commentSection)
	}
	
	func commentView(at row: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: commentSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	private var commentSection: Int {
		return 0
	}
}

extension CommentCell {
	var authorText: String? {
		return authorLabel.text
	}
	
	var messageText: String? {
		return commentLabel.text
	}
	
	var timestampText: String? {
		return timestampLabel.text
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


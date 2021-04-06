//
//  CommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Anton Ilinykh on 22.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

class CommentsSnapshotTests: XCTestCase {

	func test_emptyComments() {
		let sut = makeSUT()
		
		sut.display(emptyComments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_COMMENTS_dark")
	}

	func test_commentsWithContent() {
		let sut = makeSUT()
		
		sut.display(commentsWithContent())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "COMMENTS_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "COMMENTS_WITH_CONTENT_dark")
	}
	
	func test_commentsWithErrorMessage() {
		let sut = makeSUT()
		
		sut.display(.error(message: "This is a\nmulti-line\nerror message"))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "COMMENTS_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "COMMENTS_WITH_ERROR_MESSAGE_dark")
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> CommentsController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let controller = storyboard.instantiateViewController(identifier: "CommentsController") as! CommentsController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyComments() -> [CommentCellController] {
		return []
	}
	
	private func commentsWithContent() -> [CommentCellController] {
		return anyComments().map {
			CommentCellController(model: $0)
		}
	}
	
	private func anyComments() -> [Comment] {
		return [
			Comment(id: UUID(), message: "Facilis ea harum deleniti officia veritatis. Et sapiente saepe officia consectetur molestiae. Libero earum assumenda qui architecto repellendus ut iste non voluptatem optio", createdAt: Date().adding(days: -14), author: "Jen"),
			Comment(id: UUID(), message: "Facilis ea harum deleniti officia veritatis.", createdAt: Date().adding(days: -7), author: "Megan"),
			Comment(id: UUID(), message: "💯", createdAt: Date().adding(days: -3), author: "Jim"),
			Comment(id: UUID(), message: "Facilis ea harum deleniti officia veritatis. ☀️\n.\n.\n.\n.\n.\n.\n✅\nLibero earum assumenda qui architecto repellendus explicabo.", createdAt: Date().adding(hours: -1), author: "Brian")
		]
	}
}

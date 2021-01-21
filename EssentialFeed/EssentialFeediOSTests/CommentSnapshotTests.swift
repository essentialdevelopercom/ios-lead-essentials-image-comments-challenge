//
//  CommentSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Khoi Nguyen on 5/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
@testable import EssentialFeediOS

class CommentSnapshotTests: XCTestCase {
	func test_emptyComment() {
		let sut = makeSUT()
		
		sut.display(emptyComment())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_COMMENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_COMMENT_dark")
	}
	
	func test_commentWithContent() {
		let sut = makeSUT()
		
		sut.display(commentWithContent())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "COMMENT_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "COMMENT_WITH_CONTENT_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSizeCategory: .extraExtraExtraLarge)), named: "COMMENT_WITH_CONTENT_light_extraExtraExtraLarge")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSizeCategory: .extraExtraExtraLarge)), named: "COMMENT_WITH_CONTENT_dark_extraExtraExtraLarge")
	}
	
	func test_commentWithErrorMessage() {
		let sut = makeSUT()
		
		sut.display(.error(message: "This is a\nmulti-line\nerror message"))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "COMMENT_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "COMMENT_WITH_ERROR_MESSAGE_dark")
		assert(snapshot: sut.snapshot(
				for: .iPhone8(
					style: .light,
					contentSizeCategory: .extraExtraExtraLarge)),
			   named: "COMMENT_WITH_ERROR_MESSAGE_light_extraExtraExtraLarge")
		assert(snapshot: sut.snapshot(
				for: .iPhone8(
					style: .dark,
					contentSizeCategory: .extraExtraExtraLarge)),
			   named: "COMMENT_WITH_ERROR_MESSAGE_dark_extraExtraExtraLarge")
	}

	// MARK: - Helpers
	private func makeSUT() -> CommentViewController {
		let bundle = Bundle(for: CommentViewController.self)
		let storyboard = UIStoryboard(name: "Comment", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! CommentViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyComment() -> [CommentCellController] {
		return []
	}
	
	private func commentWithContent() -> [PresentableComment] {
		return [
			PresentableComment(
				message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
				createAt: "2 days ago",
				author: "Mark"
			),
			PresentableComment(
				message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
				createAt: "1 months ago",
				author: "Jack"
			)
		]
	}
}

private extension CommentViewController {
	func display(_ stubs: [PresentableComment]) {
		let cells: [CommentCellController] = stubs.map { stub in
			let cellController = CommentCellController(model: stub)
			return cellController
		}
		
		display(cells)
	}
}

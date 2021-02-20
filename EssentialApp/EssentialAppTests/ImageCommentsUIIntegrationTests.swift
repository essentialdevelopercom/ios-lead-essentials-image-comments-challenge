//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Raphael Silva on 20/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeediOS
import XCTest

final class ImageCommentsUIComposer {
	static func imageCommentsComposed(
		with commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
	) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let imageCommentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		imageCommentsController.delegate = ImageCommentsPresentationAdapter(loader: commentsLoader)
		return imageCommentsController
	}
}

final class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	let loader: () -> AnyPublisher<[ImageComment], Error>

	init(loader: @escaping () -> AnyPublisher<[ImageComment], Error>) {
		self.loader = loader
	}

	func didRequestCommentsRefresh() {
		_ = loader()
			.sink(
				receiveCompletion: { _ in },
				receiveValue: { _ in }
			)
	}
}

final class ImageCommentsUIIntegrationTests: XCTestCase {

	func test_loadAction_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(
			loader.loadCommentsCallCount,
			0,
			"Expected no loading requests before view is loaded"
		)

		sut.loadViewIfNeeded()
		XCTAssertEqual(
			loader.loadCommentsCallCount,
			1,
			"Expected a loading request once view is loaded"
		)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(
			loader.loadCommentsCallCount,
			2,
			"Expected a loading request once view is loaded"
		)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(
			loader.loadCommentsCallCount,
			3,
			"Expected yet another loading request once user initiates another reload"
		)
	}

	// MARK: - Helpers

	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (ImageCommentsViewController, LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposed(
			with: loader.loadPublisher
		)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	private class LoaderSpy {
		private var requests = [PassthroughSubject<[ImageComment], Error>]()

		var loadCommentsCallCount: Int { requests.count }

		func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
			let publisher = PassthroughSubject<[ImageComment], Error>()
			requests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}
	}
}

extension ImageCommentsViewController {
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
}

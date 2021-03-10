//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 09/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
@testable import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	let imageLoader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	
	init(imageLoader: ImageCommentsLoader) {
		self.imageLoader = imageLoader
	}
	
	func didRequestImageCommentsRefresh() {
		_ = imageLoader.loadImageComments(from: anyURL()) { _ in }
	}
}

final class ImageCommentsViewAdapter: ImageCommentsView {
	private weak var controller: ImageCommentsViewController?
	
	init(controller: ImageCommentsViewController) {
		self.controller = controller
	}
	
	func display(_ viewModel: ImageCommentsViewModel) {
		
	}
}

final class ImageCommentsUIComposer {
	static func imageCommentsComposedWith(imageCommentsLoader: ImageCommentsLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(imageLoader: imageCommentsLoader)
		
		let imageController = makeImageCommentsViewController(
			delegate: presentationAdapter,
			title: ImageCommentsPresenter.title)
		
		presentationAdapter.presenter = ImageCommentsPresenter(
			commentsView: ImageCommentsViewAdapter(controller: imageController),
			loadingView: WeakRefVirtualProxy(imageController),
			errorView: WeakRefVirtualProxy(imageController))
		
		return imageController
	}
	
	private static func makeImageCommentsViewController(delegate: ImageCommentsViewControllerDelegate, title: String) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let imageController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		imageController.delegate = delegate
		imageController.title = title
		return imageController
	}
}

final class ImageCommentsUIIntegrationTests: XCTestCase {
	
	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadImageCommentsAction_requestImageCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 1, "Expected a loading request once view is loaded")
	}
	
	// MARK: - Helper
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(imageCommentsLoader: loader)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		return (sut, loader)
	}
	
	private class LoaderSpy: ImageCommentsLoader, ImageCommentsViewControllerDelegate {
		private struct Task: ImageCommmentsLoaderTask {
			func cancel() { }
		}
		
		private(set) var completions = [(URL, (ImageCommentsLoader.Result) -> Void)]()
		
		var loadImageCommentsCallCount: Int {
			completions.count
		}
		
		func didRequestImageCommentsRefresh() {
			_ = loadImageComments(from: anyURL()) { _ in }
		}
		
		func loadImageComments(from url: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommmentsLoaderTask {
			completions.append((url, completion))
			return Task()
		}
	}
	
}

private extension ImageCommentsUIIntegrationTests {
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

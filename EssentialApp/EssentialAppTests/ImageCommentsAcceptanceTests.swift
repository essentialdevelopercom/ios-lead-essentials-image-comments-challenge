//
//  ImageCommentsAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Ángel Vázquez on 28/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class ImageCommentsAcceptanceTests: XCTestCase {
	func test_onImageTap_displaysCommentsWhenCustomerHasConnectivity() {
		let feed = launch(httpClient: .online(response), store: .empty)
		
		let imageComments = showImageCommentsForImage(in: feed, at: 0)
		let view1 = imageComments.imageCommentView(at: 0) as? ImageCommentCell
		let view2 = imageComments.imageCommentView(at: 1) as? ImageCommentCell
		
		XCTAssertEqual(imageComments.numberOfRenderedComments(), 2, "Expected 2 comments to be loaded")
		
		XCTAssertEqual(view1?.authorText, "an author", "Expected author to be populated with a value")
		XCTAssertEqual(view1?.messageText, "a message", "Expected message to be populated with a value")
		XCTAssertNotNil(view1?.creationDateText, "Expected creation date to be populated with a value")
		
		XCTAssertEqual(view2?.authorText, "another author", "Expected author to be populated with a value")
		XCTAssertEqual(view2?.messageText, "another message", "Expected message to be populated with a value")
		XCTAssertNotNil(view2?.creationDateText, "Expected creation date to be populated with a value")
	}
	
	func test_onImageTap_displaysErrorWhenCustomerDoesNotHaveConnectivity() {
		let feed = launch(httpClient: .online(response), imageCommentsHTTPClient: .offline, store: .empty)
		
		let imageComments = showImageCommentsForImage(in: feed, at: 0)
		
		XCTAssertEqual(imageComments.numberOfRenderedComments(), 0, "Expected no comments to be loaded")
		XCTAssertNotNil(imageComments.errorMessage, "Expected error to be shown when customer does not have connectivity")
	}
	
	// MARK: - Helpers
	
	private func launch(
		httpClient: HTTPClientStub = .offline,
		imageCommentsHTTPClient: HTTPClientStub? = nil,
		store: InMemoryFeedStore = .empty
	) -> FeedViewController {
		let sut = SceneDelegate(httpClient: httpClient, imageCommentsHTTPClient: imageCommentsHTTPClient ?? httpClient, store: store)
		sut.window = UIWindow()
		sut.configureWindow()
		
		let nav = sut.window?.rootViewController as? UINavigationController
		return nav?.topViewController as! FeedViewController
	}
	
	private func showImageCommentsForImage(in feed: FeedViewController, at index: Int, file: StaticString = #filePath, line: UInt = #line) -> ImageCommentsViewController {
		feed.simulateFeedImageViewVisible(at: index)?.simulateTapAction()
		executeRunLoopToFinishPush()
		
		let imageComments = feed.navigationController?.topViewController as? ImageCommentsViewController
		XCTAssertNotNil(imageComments, "Expected top view controller to be pushed when tapping an image", file: file, line: line)
		return imageComments!
	}
	
	private func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeData(for: url), response)
	}
	
	private func makeData(for url: URL) -> Data {
		switch url.absoluteString {
		case "http://image.com":
			return makeImageData()
		case "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/1F4A3B22-9E6E-46FC-BB6C-48B33269951B/comments":
			return makeImageCommentsData()
		default:
			return makeFeedData()
		}
	}
	
	private func makeImageData() -> Data {
		return UIImage.make(withColor: .red).pngData()!
	}
	
	private func makeFeedData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": "1F4A3B22-9E6E-46FC-BB6C-48B33269951B", "image": "http://image.com"],
			["id": "11E123D5-1272-4F17-9B91-F3D0FFEC895A", "image": "http://image.com"]
		]])
	}
	
	private func makeImageCommentsData() -> Data {
		return try! JSONSerialization.data(withJSONObject: [
			"items": [
				[
					"id": UUID().uuidString,
					"message": "a message",
					"created_at": "2020-05-20T11:24:59+0000",
					"author": ["username": "an author"]
				],
				[
					"id": UUID().uuidString,
					"message": "another message",
					"created_at": "2020-05-19T14:23:53+0000",
					"author": ["username": "another author"]
				]
			]
		])
	}
	
	private func executeRunLoopToFinishPush() {
		RunLoop.current.run(until: Date())
	}
}

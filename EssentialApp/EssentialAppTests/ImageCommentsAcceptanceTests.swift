//
//  ImageCommentsAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Sebastian Vidrea on 04.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class ImageCommentsAcceptanceTests: XCTestCase {

	func test_onLaunch_displaysRemoteImageCommentsWhenCustomerHasConnectivity() {
		let imageComments = launch(httpClient: .online(response))

		XCTAssertEqual(imageComments.numberOfRenderedImageCommentViews(), 2)
	}

	func test_onLaunch_displaysEmptyScreenWhenCustomerHasNoConnectivity() {
		let imageComments = launch(httpClient: .offline)

		XCTAssertEqual(imageComments.numberOfRenderedImageCommentViews(), 0)
	}

	// MARK: - Helpers

	private func launch(httpClient: HTTPClientStub = .offline) -> ImageCommentsViewController {
		let sut = SceneDelegate(httpClient: httpClient)
		sut.window = UIWindow()
		sut.configureWindow()
		sut.navigateToDetails(with: "id", animated: false)

		let nav = sut.window?.rootViewController as? UINavigationController
		return nav?.children.first(where: { $0 is ImageCommentsViewController }) as! ImageCommentsViewController
	}

	private func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeImageCommentsData(), response)
	}

	private func makeImageCommentsData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": UUID().uuidString, "message": "a message", "created_at": "2020-05-20T11:24:59+0000", "author": ["username": "a username"]],
			["id": UUID().uuidString, "message": "another message", "created_at": "2020-05-19T14:23:53+0000", "author": ["username": "another username"]],
		]])
	}

}

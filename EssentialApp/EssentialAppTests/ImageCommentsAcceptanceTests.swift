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
		let httpClient = HTTPClientStub.online(response)
		let sut = SceneDelegate(httpClient: httpClient)
		sut.window = UIWindow()
		sut.configureWindow()

		sut.navigateToDetails(with: "id", animated: false)

		let root = sut.window?.rootViewController
		let rootNavigation = root as? UINavigationController
		let imageComments = rootNavigation?.children.first(where: { $0 is ImageCommentsViewController }) as! ImageCommentsViewController


		XCTAssertEqual(imageComments.numberOfRenderedImageCommentViews(), 2)
	}

	// MARK: - Helpers
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

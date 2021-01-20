//
//  CommentAcceptanceTest.swift
//  EssentialAppTests
//
//  Created by Khoi Nguyen on 18/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class CommentAcceptanceTests: XCTestCase {
	func test_onLaunch_displaysRemoteCommentsWhenCustomerHasConnectivity() {
		let comment1 = makeItem(
			id: UUID(),
			message: "message 1",
			createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
			username: "username 1")
		let comment2 = makeItem(
			id: UUID(),
			message: "message 2",
			createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
			username: "username 1")
		let stubData = makeCommentsJSON(comments: [comment1.json, comment2.json])
		let models = [comment1.model, comment2.model]
		let sut = launch(httpClient: HTTPClientStub.online({ (url) -> (Data, HTTPURLResponse) in
			let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
			return (stubData, response)
		}))
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.numberOfRenderedComments(), 2)
		assertThat(sut, hasCellConfiguredWith: models, at: 0)
		assertThat(sut, hasCellConfiguredWith: models, at: 1)
	}
	
	func test_onLaunch_displayNoCommentWhenCustomerHasNoConnectivity() {
		let sut = launch(httpClient: HTTPClientStub.offline)
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.numberOfRenderedComments(), 0)
	}
	
	// MARK: - Helpers
	private func launch(httpClient: HTTPClient, file: StaticString = #file, line: UInt = #line) -> CommentViewController {
		let loader = RemoteCommentLoader(url: anyURL(), client: httpClient)
		let sut = CommentUIComposer.commentComposeWith(loader: loader)
		
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		return sut
	}
	
	private func assertThat(_ sut: CommentViewController, hasCellConfiguredWith models: [PresentableComment], at index: Int) {
		let commentView = sut.commentView(at: index) as! CommentCell
		XCTAssertEqual(commentView.messageText, models[index].message)
		XCTAssertEqual(commentView.authorText, models[index].author)
		XCTAssertEqual(commentView.timestampText, models[index].createAt)
	}
	
	private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: PresentableComment, json: [String: Any]) {
		let item = PresentableComment(
			message: message,
			createAt: RelativeTimestampGenerator.generate(with: createdAt.date, in: Locale(identifier: "en_US_POSIX")),
			author: username)
		
		let json: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.iso8601String,
			"author": [
				"username": username
			]
		]
		
		return (item, json)
	}
	
	private func makeCommentsJSON(comments: [[String: Any]]) -> Data {
		let items = ["items": comments]
		return try! JSONSerialization.data(withJSONObject: items, options: [])
	}
}

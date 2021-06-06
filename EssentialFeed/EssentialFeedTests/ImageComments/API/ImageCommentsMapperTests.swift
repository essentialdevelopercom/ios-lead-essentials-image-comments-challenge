
import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {
	func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
		let json = makeItemsJSON([])
		let samples = [199, 150, 300, 400, 500]

		try samples.forEach { code in
			XCTAssertThrowsError(
				try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code))
			)
		}
	}

	func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
		let invalidJSON = Data("invalid json".utf8)

		let samples = [200, 201, 204, 250, 299]

		try samples.forEach { code in
			XCTAssertThrowsError(
				try ImageCommentsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: code))
			)
		}
	}

	func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
		let emptyListJSON = makeItemsJSON([])

		let samples = [200, 201, 204, 250, 299]

		try samples.forEach { code in
			try assertThat(data: emptyListJSON, expectedResult: [], with: code)
		}
	}

	func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
		let item1 = makeComment(
			id: UUID(),
			message: "a message",
			createdAt: Date(),
			username: "a username"
		)

		let item2 = makeComment(
			id: UUID(),
			message: "another message",
			createdAt: Date(),
			username: "another username"
		)
		let json = makeItemsJSON([item1.json, item2.json])

		let samples = [200, 201, 204, 250, 299]
		try samples.forEach { code in
			try assertThat(data: json, expectedResult: [item1.model, item2.model], with: code)
		}
	}

	// MARK: - Helpers

	private func makeComment(id: UUID, message: String = "a message", createdAt: Date = Date(), username: String = "a username") -> (model: ImageComment, json: [String: Any]) {
		let item = ImageComment(
			id: id,
			message: message,
			createdAt: createdAt,
			username: username
		)

		let formatter = ISO8601DateFormatter()
		let date = formatter.string(from: createdAt)

		let json: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": date,
			"author": [
				"username": username
			]
		]

		return (item, json)
	}

	private func assertThat(data: Data, expectedResult: [ImageComment], with statusCode: Int) throws {
		let result = try ImageCommentsMapper.map(data, from: HTTPURLResponse(statusCode: statusCode))
		XCTAssertEqual(result, expectedResult)
	}
}

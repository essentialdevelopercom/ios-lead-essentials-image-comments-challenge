import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load { _ in }

		XCTAssertEqual(client.requestedURLs, [url])
	}

	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load { _ in }
		sut.load { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}

	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: failure(.connectivity), when: {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		})
	}

	func test_load_deliversErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()

		let samples = [199, 101, 300, 400, 500]

		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let json = makeItemsJSON([])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}

	func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()

		let samples = [200, 201, 233, 250, 299]

		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let invalidJSON = Data("invalid json".utf8)
				client.complete(withStatusCode: code, data: invalidJSON, at: index)
			})
		}
	}

	func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()

		let samples = [200, 201, 233, 250, 299]

		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success([]), when: {
				let emptyListJSON = makeItemsJSON([])
				client.complete(withStatusCode: code, data: emptyListJSON, at: index)
			})
		}
	}

	func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()

		let item1 = makeItem(
			id: UUID(),
			message: "a message",
			createdAt: ISO8601DateFormatter().date(from: "2020-05-20T11:24:59+0000")!,
			username: "a username")

		let item2 = makeItem(
			id: UUID(),
			message: "another message",
			createdAt: ISO8601DateFormatter().date(from: "2020-05-20T11:24:59+0000")!,
			username: "another username")

		let items = [item1.model, item2.model]

		let samples = [200, 201, 233, 250, 299]

		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success(items), when: {
				let json = makeItemsJSON([item1.json, item2.json])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}

	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let url = URL(string: "http://any-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)

		var capturedResults = [RemoteImageCommentsLoader.Result]()
		sut?.load { capturedResults.append($0) }

		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))

		XCTAssertTrue(capturedResults.isEmpty)
	}

	// MARK: - Helpers

	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(url: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}

	private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
		return .failure(error)
	}

	private func makeItem(id: UUID, message: String, createdAt: Date, username: String) -> (model: ImageComment, json: [String: Any]) {
		let item = ImageComment(id: id, message: message, createdAt: createdAt, username: username)

		let json = [
			"id": id.uuidString,
			"message": message,
			"created_at": ISO8601DateFormatter().string(from: createdAt),
			"author": [
				"username" : username
			]
		].compactMapValues { $0 }

		return (item, json)
	}

	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}

	private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")

		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

			case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)

			default:
				XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
			}

			exp.fulfill()
		}

		action()

		wait(for: [exp], timeout: 1.0)
	}


}

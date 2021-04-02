import XCTest
import EssentialFeed

class RemoteTaskLoaderTests: XCTestCase {

	func test_init_doesNotPerformAnyURLRequest() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		_ = sut.load(from: url) { _ in }

		XCTAssertEqual(client.requestedURLs, [url])
	}

	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		_ = sut.load(from: url) { _ in }
		_ = sut.load(from: url) { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}

	func test_load_deliversConnectivityErrorOnClientError() {
		let (sut, client) = makeSUT()
		let clientError = NSError(domain: "a client error", code: 0)

		expect(sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: clientError)
		})
	}

	func test_load_deliversErrorOnMapperError() {
		let (sut, client) = makeSUT(mapper: { _, _ in
			throw anyNSError()
		})

		expect(sut, toCompleteWith: failure(.invalidData), when: {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}

	func test_load_deliversMappedResource() {
		let resource = "a resource"
		let (sut, client) = makeSUT(mapper: { data, _ in
			String(data: data, encoding: .utf8)!
		})

		expect(sut, toCompleteWith: .success(resource), when: {
			client.complete(withStatusCode: 200, data: Data(resource.utf8))
		})
	}

	func test_cancelLoadURLTask_cancelsClientURLRequest() {
		let (sut, client) = makeSUT()
		let url = URL(string: "https://a-given-url.com")!

		let task = sut.load(from: url) { _ in }
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")

		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
	}

	func test_loadFromURL_doesNotDeliverResultAfterCancellingTask() {
		let (sut, client) = makeSUT()
		let nonEmptyData = Data("non-empty data".utf8)

		var received = [RemoteTaskLoader<String>.Result]()
		let task = sut.load(from: anyURL()) { received.append($0) }
		task.cancel()

		client.complete(withStatusCode: 404, data: anyData())
		client.complete(withStatusCode: 200, data: nonEmptyData)
		client.complete(with: anyNSError())

		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
	}

	func test_loadFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		var sut: RemoteTaskLoader? = RemoteTaskLoader<String>(client: client, mapper: { _ ,_ in "any" })

		var capturedResults = [RemoteTaskLoader<String>.Result]()
		_ = sut?.load(from: anyURL()) { capturedResults.append($0) }

		sut = nil
		client.complete(withStatusCode: 200, data: anyData())

		XCTAssertTrue(capturedResults.isEmpty)
	}

	private func makeSUT(
		url: URL = anyURL(),
		mapper: @escaping RemoteTaskLoader<String>.Mapper = { _ ,_ in "any" },
		file: StaticString = #filePath,
		line: UInt = #line) -> (sut: RemoteTaskLoader<String>, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteTaskLoader<String>(client: client, mapper: mapper)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}

	private func failure(_ error: RemoteTaskLoader<String>.Error) -> RemoteTaskLoader<String>.Result {
		return .failure(error)
	}

	private func expect(_ sut: RemoteTaskLoader<String>, toCompleteWith expectedResult: RemoteTaskLoader<String>.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let url = URL(string: "https://a-given-url.com")!
		let exp = expectation(description: "Wait for load completion")

		_ = sut.load(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)

			case let (.failure(receivedError), .failure(expectedError)):
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

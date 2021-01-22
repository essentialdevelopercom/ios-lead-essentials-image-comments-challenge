//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedImageCommentsFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotRequestFromURL() {
        let client = HTTPClientSpy()
        _ = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        _ = sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        _ = sut.load { _ in }
        _ = sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = anyNSError()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: clientError)
        })
    }
    
    func test_loadFromURL_deliversInvalidDataErrorOnNon2XXHTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 300, 404, 503]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            })
        }
    }
    
    func test_loadFromURL_deliversInvalidDataErrorOn2XXHTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        let samples = [200, 201, 245, 298, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let emptyData = Data()
                client.complete(withStatusCode: code, data: emptyData,at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn2XXHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        let samples = [200, 201, 245, 298, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let invalidJson = Data("Invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJson, at: index)
            }
        }
    }
    
    func test_load_deliversNoItemsOn2XXHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let samples = [200, 201, 245, 298, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([]), when: {
                let emptyListJSON = Data("{\"items\": [] }".utf8)
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            })
        }
    }
    
    func test_load_deliversItemsOn2XXHTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let date1 = (Date(timeIntervalSince1970: 1589898233), "2020-05-19T14:23:53+0000")
        let date2 = (Date(timeIntervalSince1970: 1589973899), "2020-05-20T11:24:59+0000")
        
        let item1 = makeItem(id: UUID(), message: "First message", createdAt: date1, author: "First author")
        let item2 = makeItem(id: UUID(), message: "Second message", createdAt: date2, author: "Second author")
        let items = [item1.model, item2.model]

        let samples = [200, 201, 245, 298, 299]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(items), when: {
                let json = makeItemsJSON([item1.json, item2.json])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = anyURL()
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageCommentsLoader? = RemoteFeedImageCommentsLoader(client: client, url: url)
        
        var capturedResults = [RemoteFeedImageCommentsLoader.Result]()
        _ = sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_cancelLoadComments_cancelsClientURLRequest() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        let task = sut.load { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)

        var received = [FeedImageCommentsLoader.Result]()
        let task = sut.load { received.append($0) }
        task.cancel()
        
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = anyURL(),file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageCommentsLoader, client: HTTPClientSpy) {
        let url = anyURL()
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageCommentsLoader(client: client, url: url)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedImageCommentsLoader.Error) -> RemoteFeedImageCommentsLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601: String), author: String) -> (model: FeedImageComment, json: [String: Any]) {
        let model = FeedImageComment( id: id, message: message, createdAt: createdAt.date, author: author)
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601,
            "author": [
                "username": author
            ]
        ].compactMapValues { $0 }

        return (model, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteFeedImageCommentsLoader, toCompleteWith expectedResult: RemoteFeedImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedData), .success(expectedData)):
                    XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                    
                case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
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
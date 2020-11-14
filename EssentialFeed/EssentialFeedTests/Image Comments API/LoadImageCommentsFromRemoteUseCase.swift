//
//  LoadImageCommentsFromRemoteUseCase.swift
//  EssentialFeedTests
//
//  Created by Araceli Ruiz Ruiz on 08/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCase: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_ , client) = makeSUT()
       
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadComments_requestDataFromURL() {
        let (sut, client) = makeSUT()
        
        sut.loadComments(from: anyURL()) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [anyURL()])
    }
    
    func test_loadCommentsTwice_requestDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadComments(from: url) { _ in }
        sut.loadComments(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadComments_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .failure(RemoteImageCommentsLoader.Error.connectivity), when: {
            client.complete(with: NSError(domain: "", code: 0))
        })

    }
    
    func test_loadComments_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWith: .failure(RemoteImageCommentsLoader.Error.invalidData), when: {
                client.complete(withStatusCode: code, data: Data(), at: index)
            })
        }
    }
    
    func test_loadComments_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .failure(RemoteImageCommentsLoader.Error.invalidData), when: {
            let invalidData = Data("invalidData".utf8)
            client.complete(withStatusCode: 200, data: invalidData)
        })
    }
    
    func test_loadComments_deliversNoItemsOn200HTTPResponseWithEmptyJson() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .success([]), when: {
            let emptyJSON = Data("{\"items\": [] }".utf8)
            client.complete(withStatusCode: 200, data: emptyJSON)
        })
    }
    
    func test_loadComments_deliversItemsOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let comment1 = makeItem(
            id: UUID(),
            message: "message1",
            createdAt: (Date(timeIntervalSince1970: 1604924092), "2020-11-09T13:14:52+0100"),
            username: "username1")
        
       
        let comment2 = makeItem(
            id: UUID(),
            message: "message2",
            createdAt: (Date(timeIntervalSince1970: 1604924092), "2020-11-09T13:14:52+0100"),
            username: "username2")
                
        let commentsJSON = [
            "items": [comment1.json, comment2.json]
        ]
        
        expect(sut: sut, toCompleteWith: .success([comment1.comment, comment2.comment])) {
            let json = try! JSONSerialization.data(withJSONObject: commentsJSON)
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_loadComments_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = anyURL()
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(client: client)
        
        var capturedResults = [RemoteImageCommentsLoader.Result]()
        sut?.loadComments(from: url) { capturedResults.append($0) }

        sut = nil
        let emptyJSON = Data("{\"items\": [] }".utf8)
        client.complete(withStatusCode: 200, data: emptyJSON)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (comment: ImageComment, json: [String: Any]) {
        
        let comment = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
    
        let commentJSON: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]]
        
        return(comment, commentJSON)
        
    }
            
    private func expect(sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        sut.loadComments(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedComments), .success(expectedComments)):
                XCTAssertEqual(receivedComments, expectedComments, file: file, line: line)
                
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

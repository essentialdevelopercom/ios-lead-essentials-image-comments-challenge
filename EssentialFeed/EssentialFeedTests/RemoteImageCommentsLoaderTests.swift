//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Araceli Ruiz Ruiz on 08/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteImageCommentsLoader {
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    enum Result {
        case success([ImageComment])
        case failure(Error)
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadComments(from url: URL, completion: @escaping (Result) -> Void = { _ in }) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.failure(.invalidData))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

class RemoteImageCommentsLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_ , client) = makeSUT()
       
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadComments_requestDataFromURL() {
        let (sut, client) = makeSUT()
        
        sut.loadComments(from: anyURL())
        
        XCTAssertEqual(client.requestedURLs, [anyURL()])
    }
    
    func test_loadCommentsTwice_requestDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadComments(from: url)
        sut.loadComments(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadComments_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteImageCommentsLoader.Error]()
        sut.loadComments(from: anyURL()) { capturedErrors.append($0) }
        
        client.complete(with: NSError(domain: "", code: 0))

        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_loadComments_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteImageCommentsLoader.Error]()
            sut.loadComments(from: anyURL()) { capturedErrors.append($0) }
            
            client.complete(withStatusCode: code, data: Data(), at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    func test_loadComments_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteImageCommentsLoader.Error]()
        let invalidData = Data("invalidData".utf8)
        
        sut.loadComments(from: anyURL()) { capturedErrors.append($0) }
        
        client.complete(withStatusCode: 200, data: invalidData)
        
        XCTAssertEqual(capturedErrors, [.invalidData])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
}

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
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadComments(from url: URL, completion: @escaping (Error) -> Void = { _ in }) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
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
        
        var capturedErrors = [RemoteImageCommentsLoader.Error]()
        sut.loadComments(from: anyURL()) { capturedErrors.append($0) }
        
        client.complete(withStatusCode: 400, data: Data())

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

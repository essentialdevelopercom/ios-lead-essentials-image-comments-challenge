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
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadComments(from url: URL) {
        client.get(from: url) { _ in }
    }
}

class RemoteImageCommentsLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteImageCommentsLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadComments_requestDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(client: client)
        
        sut.loadComments(from: anyURL())
        
        XCTAssertEqual(client.requestedURLs, [anyURL()])
    }

    
}

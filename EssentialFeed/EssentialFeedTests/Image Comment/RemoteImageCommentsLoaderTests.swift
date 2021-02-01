//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 01/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

class RemoteImageCommentsLoader {
	private let client: HTTPImageClient
	private let url: URL
	
	init(client: HTTPImageClient, url: URL) {
		self.client = client
		self.url = url
	}
	
	func load() {
		client.get(from: url)
	}
}

class HTTPImageClient {
	var requestedUrls = [URL]()
	
	func get(from url: URL) {
		requestedUrls.append(url)
	}
}

class RemoteImageCommentsLoaderTests: XCTestCase {
	func test_init_doesNotRequestDataFromUrl() {
		let (_, client) = makeSUT()
		
		XCTAssertEqual(client.requestedUrls, [])
	}
	
	func test_everyTimeloadIsCalled_requestsDataFromUrl() {
		let (sut, client) = makeSUT()
		let url = URL(string: "https://a-url.com")!
		
		sut.load()
		XCTAssertEqual(client.requestedUrls, [url])
		
		sut.load()
		sut.load()
		XCTAssertEqual(client.requestedUrls, [url,url,url])
	}
	
	//MARK: Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPImageClient){
		let client = HTTPImageClient()
		let sut = RemoteImageCommentsLoader(client: client, url: url)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut,client)
	}
}

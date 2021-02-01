//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 01/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

protocol HTTPImageClient{
	func get(from url: URL, completion: @escaping (Error) -> Void)
}

class RemoteImageCommentsLoader {
	private let client: HTTPImageClient
	private let url: URL
	
	init(client: HTTPImageClient, url: URL) {
		self.client = client
		self.url = url
	}
	
	public enum Error: Swift.Error {
		case connectivity
	}
	
	func load(completion: @escaping (Error) -> Void) {
		client.get(from: url) { _ in
			completion(.connectivity)
		}
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
		
		sut.load { _ in }
		XCTAssertEqual(client.requestedUrls, [url])
		
		sut.load { _ in }
		sut.load { _ in }
		XCTAssertEqual(client.requestedUrls, [url,url,url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		client.completeWithError = true
		
		sut.load() { error in
			XCTAssertEqual(error as RemoteImageCommentsLoader.Error, .connectivity)
		}
	}
	
	//MARK: Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPImageClientSpy){
		let client = HTTPImageClientSpy()
		let sut = RemoteImageCommentsLoader(client: client, url: url)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut,client)
	}
	
	private class HTTPImageClientSpy: HTTPImageClient {
		var completeWithError = false
		var requestedUrls = [URL]()
		
		func get(from url: URL, completion: @escaping (Error) -> Void) {
			requestedUrls.append(url)
			if completeWithError {
				completion(NSError())
			}
		}
	}
}

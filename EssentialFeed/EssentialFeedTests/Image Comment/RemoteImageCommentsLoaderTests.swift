//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 01/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

protocol HTTPImageClient{
	func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
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
		case invalidData
	}
	
	func load(completion: @escaping (Error) -> Void) {
		client.get(from: url) { error, _  in
			if error != nil {
				completion(.connectivity)
			} else {
				completion(.invalidData)
			}
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
		
		sut.load() { error in
			XCTAssertEqual(error as RemoteImageCommentsLoader.Error, .connectivity)
		}
		
		client.complete(with: NSError())
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		let statusCodes = [111,222,300,400,500]
		
		statusCodes.enumerated().forEach { index, code in
			sut.load() { error in
				XCTAssertEqual(error as RemoteImageCommentsLoader.Error, .invalidData)
			}
			
			client.complete(withStatusCode: code, at: index)
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
		var completions = [(Error?, HTTPURLResponse?) -> Void]()
		var requestedUrls = [URL]()
		
		func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
			requestedUrls.append(url)
			completions.append(completion)
		}
		
		func complete(with error: NSError, at index: Int = 0) {
			completions[index](error, nil)
		}
		
		func complete(withStatusCode code: Int, at index: Int = 0) {
			let response = HTTPURLResponse(url: requestedUrls[index],
										   statusCode: code,
										   httpVersion: nil,
										   headerFields: nil)
			completions[index](nil, response)
		}
	}
}

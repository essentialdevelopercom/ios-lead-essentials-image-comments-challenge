//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 01/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

struct ImageComment: Equatable {}

protocol HTTPImageClient{
	typealias Result = Swift.Result<(Data, HTTPURLResponse),Error>
	
	func get(from url: URL, completion: @escaping (Result) -> Void)
}

class RemoteImageCommentsLoader {
	typealias Result = Swift.Result<[ImageComment], Error>
	
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
	
	func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result  in
			if let _ = try? result.get() {
				completion(.failure(.invalidData))
			} else {
				completion(.failure(.connectivity))
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
		
		expect(sut: sut, toCompleteWith: .failure(.connectivity), when: {
			client.complete(with: NSError())
		})
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		let statusCodes = [111,222,300,400,500]
		
		statusCodes.enumerated().forEach { index, code in
			expect(sut: sut, toCompleteWith: .failure(.invalidData), when: {
				client.complete(withStatusCode: code, at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		let invalidJSON = Data("invalid json".utf8)
		
		expect(sut: sut, toCompleteWith: .failure(.invalidData), when: {
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}
	
	//MARK: Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPImageClientSpy){
		let client = HTTPImageClientSpy()
		let sut = RemoteImageCommentsLoader(client: client, url: url)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut,client)
	}
	
	private func expect(sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		sut.load() { recievedResult in
			switch (recievedResult, expectedResult) {
			case let (.failure(recievedError), .failure(expectedError)):
				XCTAssertEqual(recievedError, expectedError, file: file, line: line)
			case let (.success(recievedComments), .success(expectedComments)):
				XCTAssertEqual(recievedComments, expectedComments, file: file, line: line)
			default:
				XCTFail("Expected result: \(expectedResult), got: \(recievedResult) instead", file: file, line: line)
			}
		}
		
		action()
	}
	
	private class HTTPImageClientSpy: HTTPImageClient {
		var completions = [(HTTPImageClient.Result) -> Void]()
		var requestedUrls = [URL]()
		
		func get(from url: URL, completion: @escaping (HTTPImageClient.Result) -> Void) {
			requestedUrls.append(url)
			completions.append(completion)
		}
		
		func complete(with error: NSError, at index: Int = 0) {
			completions[index](.failure(error))
		}
		
		func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
			let response = HTTPURLResponse(url: requestedUrls[index],
										   statusCode: code,
										   httpVersion: nil,
										   headerFields: nil)!
			completions[index](.success((data, response)))
		}
	}
}

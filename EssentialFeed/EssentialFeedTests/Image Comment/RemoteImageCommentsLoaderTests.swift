//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 01/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

struct ImageComment: Equatable {
	let id: UUID
	let message: String
	let createdDate: Date
	let author: CommentAuthor
}

struct CommentAuthor: Equatable{
	let username: String
}

protocol HTTPImageClient{
	typealias Result = Swift.Result<(Data, HTTPURLResponse),Error>
	
	func get(from url: URL, completion: @escaping (Result) -> Void)
}

class RemoteImageCommentsLoader {
	typealias Result = Swift.Result<[ImageComment], Error>
	
	private struct Root: Decodable {
		let items: [RemoteImageComment]
		
		var imageComments: [ImageComment] {
			return items.map { ImageComment(id: $0.id, message: $0.message, createdDate: $0.created_at, author: CommentAuthor(username: $0.author.username))}
		}
	}
	
	private struct RemoteImageComment: Decodable {
		let id: UUID
		let message: String
		let created_at: Date
		let author: RemoteCommentAuthor
	}
	
	struct RemoteCommentAuthor: Decodable {
		let username: String
	}
	
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
		client.get(from: url) { [weak self] result  in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				if response.statusCode == 200 {
					let jsonDecoder = JSONDecoder()
					jsonDecoder.dateDecodingStrategy = .iso8601
					do {
					let root = try jsonDecoder.decode(Root.self, from: data)
						completion(.success(root.imageComments))
					} catch {
						completion(.failure(.invalidData))
					}
				} else {
					completion(.failure(.invalidData))
				}
			case .failure:
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
	
	func test_load_deliversEmptyCommentsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		let emptyJSON = Data("{\"items\":[]}".utf8)
		
		expect(sut: sut, toCompleteWith: .success([]), when: {
			client.complete(withStatusCode: 200, data: emptyJSON)
		})
	}
	
	func test_load_deliversCommentsOn200ResponseWithValidJSONList() {
		let (sut, client) = makeSUT()
		
		let (comment1, commentJSON1) = makeImageItem(id: UUID(),
												   message: "a message",
												   created_at: Date(timeIntervalSince1970: 1000000),
												   username: "user")
		let (comment2, commentJSON2) = makeImageItem(id: UUID(),
												   message: "another message",
												   created_at: Date(timeIntervalSince1970: 500000),
												   username: "another user")
		
		let validJSON = makeItemsJSON([commentJSON1, commentJSON2])
		
		expect(sut: sut, toCompleteWith: .success([comment1,comment2]), when: {
				client.complete(withStatusCode: 200, data: validJSON)
		})
	}
	
	func test_load_shouldNotDeliverResultOnDeallocation() {
		let url = URL(string: "https://a-url.com")!
		let client = HTTPImageClientSpy()
		var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(client: client, url: url)
		
		var capturedResults = [RemoteImageCommentsLoader.Result]()
		sut?.load { capturedResults.append($0) }
		
		sut = nil
		client.complete(with: NSError())
		
		XCTAssertEqual(capturedResults, [])
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
	
	private func makeImageItem(id: UUID, message: String, created_at: Date, username: String) -> (model: ImageComment, json: [String: Any]) {
		let author = CommentAuthor(username: username)
		let comment = ImageComment(id: id, message: message, createdDate: created_at, author: author)
		
		let iso8601DateFormatter = ISO8601DateFormatter()
		let dateString = iso8601DateFormatter.string(from: comment.createdDate)
		
		let authorJSON = [
			"username": author.username
		]
		let commentJSON = [
			"id": comment.id.uuidString,
			"message": comment.message,
			"created_at": dateString,
			"author": authorJSON
		] as [String: Any]
		
		return (comment, commentJSON)
	}
	
	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
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

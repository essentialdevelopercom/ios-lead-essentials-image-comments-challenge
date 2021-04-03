//
//  Created by Azamat Valitov on 13.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteFeedCommentsLoader: FeedCommentsLoader {
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	private let client: HTTPClient
	public init(client: HTTPClient) {
		self.client = client
	}
	
	private final class HTTPClientTaskWrapper: FeedCommentsLoaderTask {
		private var completion: ((FeedCommentsLoader.Result) -> Void)?
		
		var wrapped: HTTPClientTask?
		
		init(_ completion: @escaping (FeedCommentsLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: FeedCommentsLoader.Result) {
			completion?(result)
		}
		
		func cancel() {
			preventFurtherCompletions()
			wrapped?.cancel()
		}
		
		private func preventFurtherCompletions() {
			completion = nil
		}
	}
	
	@discardableResult
	public func load(url: URL, completion: @escaping (Result<[FeedComment], Swift.Error>)->()) -> FeedCommentsLoaderTask {
		let task = HTTPClientTaskWrapper(completion)
		task.wrapped = client.get(from: url, completion: {[weak self] result in
			guard let self = self else { return }
			self.handle(result, task)
		})
		return task
	}
	
	private func handle(_ result: HTTPClient.Result, _ task: HTTPClientTaskWrapper) {
		switch result {
		case .success(let (data, response)):
			handleSuccessCase(data, response, task)
		case .failure:
			task.complete(with: .failure(Error.connectivity))
		}
	}
	
	private func handleSuccessCase(_ data: Data, _ response: HTTPURLResponse, _ task: HTTPClientTaskWrapper) {
		if response.statusCode == 200, let comments = try? convert(data) {
			task.complete(with: .success(comments))
		} else {
			task.complete(with: .failure(Error.invalidData))
		}
	}
	
	private func convert(_ data: Data) throws -> [FeedComment] {
		let root = try decoder.decode(Root.self, from: data)
		return root.items.map({FeedComment(id: $0.id, message: $0.message, date: $0.created_at, authorName: $0.author.username)})
	}
	
	private lazy var decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}()
}

private struct Root: Decodable {
	let items: [RemoteFeedComment]
}

private struct RemoteFeedComment: Decodable {
	let id: UUID
	let message: String
	let created_at: Date
	let author: RemoteAuthor
}

private struct RemoteAuthor: Decodable {
	let username: String
}

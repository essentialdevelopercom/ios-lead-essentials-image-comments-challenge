//
//  Created by Azamat Valitov on 13.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteFeedCommentsLoader {
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	private let client: HTTPClient
	public init(client: HTTPClient) {
		self.client = client
	}
	
	public func load(url: URL, completion: @escaping (Result<[FeedComment], Error>)->()) {
		client.get(from: url, completion: {[weak self] result in
			guard let _ = self else { return }
			switch result {
			case .success(let (data, response)):
				let decoder = JSONDecoder()
				decoder.dateDecodingStrategy = .iso8601
				if response.statusCode == 200, let root = try? decoder.decode(Root.self, from: data) {
					completion(.success(root.items.map({FeedComment(id: $0.id, message: $0.message, date: $0.created_at, authorName: $0.author.username)})))
				}else{
					completion(.failure(.invalidData))
				}
			case .failure:
				completion(.failure(.connectivity))
			}
		})
	}
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

//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 09/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteImageCommentsLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result {
        case success([ImageComment])
        case failure(Error)
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadComments(from url: URL, completion: @escaping (Result) -> Void = { _ in }) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, _)):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let root = try? decoder.decode(Root.self, from: data) {
                    completion(.success(root.items.map { $0.item }))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }

}

private struct Root: Decodable {
    let items: [Item]
}

private struct Item: Decodable {
    private let id: UUID
    private let message: String
    private let created_at: Date
    private let author: ImageCommentAuthor
    
    var item: ImageComment {
        return ImageComment(id: id, message: message, createdAt: created_at, author: author)
    }
    
}


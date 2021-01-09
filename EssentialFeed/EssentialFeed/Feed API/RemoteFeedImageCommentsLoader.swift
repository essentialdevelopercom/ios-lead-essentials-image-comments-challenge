//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedImageCommentsLoader: FeedImageCommentsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedImageCommentsLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) -> HTTPClientTask {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
                case let .success((data, response)):
                    completion(RemoteFeedImageCommentsLoader.map(data, from: response))
                    
                case .failure:
                    completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedImageCommentsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(Error.invalidData)
        }
    }
}

private extension Array where Element == RemoteImageCommentsItem {
    func toModels() -> [FeedImageComment] {
        map { FeedImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: $0.author.username) }
    }
}

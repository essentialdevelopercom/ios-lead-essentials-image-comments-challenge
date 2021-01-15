//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedImageCommentsLoader: FeedImageCommentsLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: FeedImageCommentsLoaderTask {
        private var completion: ((FeedImageCommentsLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (FeedImageCommentsLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageCommentsLoader.Result) {
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
    
    public func load(from url: URL, completion: @escaping (RemoteFeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
                case let .success((data, response)):
                    task.complete(with: RemoteFeedImageCommentsLoader.map(data, from: response))
                    
                case .failure:
                    task.complete(with: .failure(Error.connectivity))
            }
        }
        return task
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedImageCommentsLoader.Result {
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

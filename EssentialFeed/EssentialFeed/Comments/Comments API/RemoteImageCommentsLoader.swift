//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentsLoader: ImageCommentsLoader {
    let client: HTTPClient

    public typealias Result = ImageCommentsLoader.Result

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(client: HTTPClient) {
        self.client = client
    }

    private final class HTTPClientTaskWrapper: ImageCommentsLoaderTask {
        private var completion: ((Result) -> Void)?
        var wrappedTask: HTTPClientTask?

        init(completion: @escaping (Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: Result) {
            completion?(result)
        }

        func cancel() {
            wrappedTask?.cancel()
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    public func load(from url: URL, completion: @escaping (Result) -> Void) -> ImageCommentsLoaderTask {
        let task = HTTPClientTaskWrapper(completion: completion)
        task.wrappedTask = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                task.complete(with: RemoteImageCommentsLoader.map(data, from: response))
            case .failure:
                task.complete(with: .failure(Error.connectivity))
            }
        }
        return task
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentsItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteImageCommentItem {
    func toModels() -> [ImageComment] {
        map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: $0.author.username) }
    }
}

//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import Foundation

extension ImageCommentsUIIntegrationTests {
    class LoaderSpy: ImageCommentsLoader {
        var loadCommentsCallCount: Int { completions.count }
        var completions = [(ImageCommentsLoader.Result) -> Void]()
        private(set) var cancelledRequests = [URL]()

        private struct Task: ImageCommentsLoaderTask {
            let cancelCallback: () -> Void

            func cancel() {
                cancelCallback()
            }
        }

        func load(from url: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
            completions.append(completion)
            return Task { [weak self] in
                self?.cancelledRequests.append(url)
            }
        }

        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            completions[index](.success(comments))
        }

        func completeCommentsLoading(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}

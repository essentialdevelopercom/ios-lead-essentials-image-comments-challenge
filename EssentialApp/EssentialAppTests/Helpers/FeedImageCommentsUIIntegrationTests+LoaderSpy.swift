//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

extension FeedImageCommentsUIIntegrationTests {
    
    class LoaderSpy: FeedImageCommentsLoader {
        private var completions = [(FeedImageCommentsLoader.Result) -> Void]()
        var loadCount: Int { return completions.count }
        private(set) var cancelCount = 0
        
        private struct Task: FeedImageCommentsLoaderTask {
            let cancelCallback: () -> Void

            func cancel() {
                cancelCallback()
            }
        }
        
        func load(completion: @escaping (FeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
            completions.append(completion)
            return Task { [weak self] in
                self?.cancelCount += 1
            }
        }
        
        func completeCommentsLoading(with comments: [FeedImageComment] = [], at index: Int = 0) {
            completions[index](.success(comments))
        }
        
        func completeCommentsLoading(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}

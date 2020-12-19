//
//  ImageCommentsUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

extension ImageCommentsUIIntegrationTests {
    class LoaderSpy: ImageCommentsLoader {
        private var completions = [(ImageCommentsLoader.Result) -> Void]()
        private var cancelledCompletions = [(ImageCommentsLoader.Result) -> Void]()
        
        var loadCallsCount: Int {
            completions.count
        }
        
        var cancelledLoadCallsCount: Int {
            cancelledCompletions.count
        }

        private struct TaskSpy: ImageCommentsLoaderTask {
            let cancelCallBack: () -> Void
            

            func cancel() {
                cancelCallBack()
            }
        }
        
        func loadComments(from url: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
            completions.append(completion)
            return TaskSpy { self.cancelledCompletions.append(completion) }
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int) {
            completions[index](.success(comments))
        }
        
        func completeCommentsLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            completions[index](.failure(error))
        }
    }
}

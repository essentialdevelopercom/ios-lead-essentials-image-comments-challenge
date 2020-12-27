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
        private(set) var cancelledLoadCallsCount = 0
        
        var loadCallsCount: Int {
            completions.count
        }
        
        private struct TaskSpy: ImageCommentsLoaderTask {
            let cancelCallBack: () -> Void
            
            func cancel() {
                cancelCallBack()
            }
        }
        
        func loadComments(from url: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
            completions.append(completion)
            return TaskSpy { self.cancelledLoadCallsCount += 1 }
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

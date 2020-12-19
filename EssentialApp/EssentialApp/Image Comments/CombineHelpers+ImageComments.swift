//
//  CombineHelpers+ImageComments.swift
//  EssentialApp
//
//  Created by Araceli Ruiz Ruiz on 19/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import Combine
import EssentialFeed

public extension ImageCommentsLoader {
    typealias Publisher = AnyPublisher<[ImageComment], Error>
    
    func loadCommentsPublisher(from url: URL) -> Publisher {
        var task: ImageCommentsLoaderTask?
        
        return Deferred {
            Future { completion in
                task = self.loadComments(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

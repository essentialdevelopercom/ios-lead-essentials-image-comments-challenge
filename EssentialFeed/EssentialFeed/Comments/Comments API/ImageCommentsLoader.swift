//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsLoaderTask {
    func cancel()
}

public protocol ImageCommentsLoader {
    typealias Result = Swift.Result<[ImageComment], Swift.Error>
    func load(from url: URL, completion: @escaping (Result) -> Void) -> ImageCommentsLoaderTask
}

//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentsLoader {
    typealias Result = Swift.Result<[FeedImageComment], Error>
    
    func load(completion: @escaping (Result) -> Void)
}

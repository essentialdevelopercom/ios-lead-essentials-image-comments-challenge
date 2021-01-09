//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageCommentsItem: Codable, Equatable {
    
    struct Author: Codable, Equatable {
        let username: String
    }
    
    let id: UUID
    let message: String
    let created_at: Date
    let author: Author
}

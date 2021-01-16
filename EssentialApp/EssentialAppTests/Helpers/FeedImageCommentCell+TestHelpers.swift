//
//  Created by Flavio Serrazes on 16.01.21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedImageCommentCell {
    
    var usernameText: String? {
        return usernameLabel?.text
    }
    
    var createdAtText: String? {
        return createdAtLabel?.text
    }
    
    var commentText: String? {
        return commentLabel?.text
    }
}


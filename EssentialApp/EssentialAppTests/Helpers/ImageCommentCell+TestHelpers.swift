//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeediOS
import UIKit

extension ImageCommentCell {
    var commentText: String? {
        commentLabel?.text
    }

    var usernameText: String? {
        usernameLabel?.text
    }

    var createdAtText: String? {
        createdAtLabel?.text
    }
}

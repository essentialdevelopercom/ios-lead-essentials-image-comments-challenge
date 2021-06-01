//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension ImageCommentCell {
	var usernameText: String? {
		return usernameLabel.text
	}

	var createAtText: String? {
		return createAtLabel.text
	}

	var messageText: String? {
		return descriptionLabel.text
	}
}

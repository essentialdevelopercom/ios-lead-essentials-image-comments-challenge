//
//  FeedImageCommentCell+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Maxim Soldatov on 12/1/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedImageCommentCell {
	
	var usernameLabelText: String? {
		return usernameLabel?.text
	}
	
	var creationTimeText: String? {
		return creationTimeLabel?.text
	}
	
	var commentText: String? {
		return commentLabel?.text
	}
}


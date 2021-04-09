//
//  FeedImageCommentCell+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Ivan Ornes on 5/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedImageCommentCell {
	
	var messageText: String? {
		return messageLabel.text
	}

	var createdAtText: String? {
		return createdAtLabel.text
	}

	var authorText: String? {
		return authorLabel.text
	}
}

//
//  CommentCell+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Khoi Nguyen on 7/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension CommentCell {
	var authorText: String? {
		return authorLabel?.text
	}
	
	var messageText: String? {
		return commentLabel?.text
	}
	
	var timestampText: String? {
		return timestampLabel?.text
	}
}

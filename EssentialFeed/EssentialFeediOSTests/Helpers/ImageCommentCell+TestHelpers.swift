//
//  ImageCommentCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Mayorga on 4/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import UIKit
import EssentialFeediOS

extension ImageCommentCell {
	var authorNameText: String? {
		return authorName.text
	}
	
	var commentText: String? {
		return comment.text
	}
	
	var dateText: String? {
		return datePosted.text
	}
}

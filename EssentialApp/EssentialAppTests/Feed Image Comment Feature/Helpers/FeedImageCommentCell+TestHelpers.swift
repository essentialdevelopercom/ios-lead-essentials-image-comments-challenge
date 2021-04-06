//
//  FeedImageCommentCell+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Mario Alberto Barragán Espinosa on 11/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedImageCommentCell {
	var authorNameText: String? {
		return authorNameLabel.text
	}
	
	var messageText: String? {
		return messageLabel.text
	}
	
	var createdAtText: String? {
		return createdAtLabel.text
	}
}

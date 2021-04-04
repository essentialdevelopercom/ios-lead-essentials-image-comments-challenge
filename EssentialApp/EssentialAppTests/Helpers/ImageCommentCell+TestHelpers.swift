//
//  ImageCommentCell+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Sebastian Vidrea on 04.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeediOS

extension ImageCommentCell {
	var messageText: String? {
		messageLabel.text
	}

	var authorNameText: String? {
		authorNameLabel.text
	}

	var createdAtText: String? {
		createdAtLabel.text
	}
}

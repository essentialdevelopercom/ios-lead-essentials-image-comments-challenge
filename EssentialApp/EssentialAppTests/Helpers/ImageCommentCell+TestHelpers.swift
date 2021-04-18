//
//  ImageCommentCell+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Ángel Vázquez on 28/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeediOS

extension ImageCommentCell {
	var authorText: String? {
		authorLabel?.text
	}
	
	var creationDateText: String? {
		creationDateLabel?.text
	}
	
	var messageText: String? {
		messageLabel?.text
	}
}

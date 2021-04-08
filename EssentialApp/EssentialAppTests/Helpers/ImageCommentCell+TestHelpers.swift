//
//  ImageCommentCell+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Bogdan Poplauschi on 02/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension ImageCommentCell {
	var commentText: String? { commentLabel?.text }
	var usernameText: String? { usernameLabel?.text }
	var createdAtText: String? { createdAtLabel?.text }
}

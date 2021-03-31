//
//  ImageCommentCell.swift
//  EssentialFeediOS
//
//  Created by Lukas Bahrle Santana on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentCell: UITableViewCell {
	@IBOutlet private(set) public var messageLabel: UILabel!
	@IBOutlet private(set) public var createdAtLabel: UILabel!
	@IBOutlet private(set) public var usernameLabel: UILabel!
	
	func configure(imageComment: PresentableImageComment) {
		messageLabel.text = imageComment.message
		createdAtLabel.text = imageComment.createdAt
		usernameLabel.text = imageComment.username
	}
}

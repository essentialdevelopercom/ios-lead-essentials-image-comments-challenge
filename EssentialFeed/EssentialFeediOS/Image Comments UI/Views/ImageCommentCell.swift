//
//  ImageCommentCell.swift
//  EssentialFeediOS
//
//  Created by Raphael Silva on 20/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public final class ImageCommentCell:
	UITableViewCell
{
	@IBOutlet
	private(set) public var usernameLabel: UILabel!

	@IBOutlet
	private(set) public var dateLabel: UILabel!

	@IBOutlet
	private(set) public var messageLabel: UILabel!
}

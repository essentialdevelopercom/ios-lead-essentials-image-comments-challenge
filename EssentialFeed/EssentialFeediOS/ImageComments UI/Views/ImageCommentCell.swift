//
//  ImageCommentCell.swift
//  EssentialFeediOS
//
//  Created by Eric Garlock on 3/11/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public class ImageCommentCell: UITableViewCell {
	@IBOutlet public var labelMessage: UILabel!
	@IBOutlet public var labelCreated: UILabel!
	@IBOutlet public var labelUsername: UILabel!
	
	public func configure(_ viewModel: ImageCommentViewModel) {
		labelMessage.text = viewModel.message
		labelCreated.text = viewModel.created
		labelUsername.text = viewModel.username
	}
}

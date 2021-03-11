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
	public let message = UILabel()
	public let created = UILabel()
	public let username = UILabel()
	
	public func configure(_ viewModel: ImageCommentViewModel) {
		message.text = viewModel.message
		created.text = viewModel.created
		username.text = viewModel.username
	}
}

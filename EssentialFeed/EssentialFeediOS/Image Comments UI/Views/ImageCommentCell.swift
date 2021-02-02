//
//  ImageCommentCell.swift
//  EssentialFeediOS
//
//  Created by Lukas Bahrle Santana on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public class ImageCommentCell: UITableViewCell{
	public let message = UILabel()
	public let createdAt = UILabel()
	public let username = UILabel()
	
	
	func configure(imageComment: PresentableImageComment){
		message.text = imageComment.message
		createdAt.text = imageComment.createdAt
		username.text = imageComment.username
	}
}

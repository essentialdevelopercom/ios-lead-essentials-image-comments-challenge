//
//  FeedCommentCell.swift
//  EssentialFeediOS
//
//  Created by Danil Vassyakin on 3/31/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public final class FeedCommentCell: UITableViewCell {
	
	@IBOutlet private(set) weak var authorNameLabel: UILabel!
	@IBOutlet private(set) weak var commentTimeLabel: UILabel!
	@IBOutlet private(set) weak var commentTextLabel: UILabel!
	
	public func configure(authorName: String, commentDate: String, commentText: String) {
		authorNameLabel.text = authorName
		commentTimeLabel.text = commentDate
		commentTextLabel.text = commentText
	}
	
}

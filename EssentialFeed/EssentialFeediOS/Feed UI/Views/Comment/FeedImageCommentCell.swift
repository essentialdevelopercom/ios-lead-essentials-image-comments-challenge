//
//  FeedImageCommentCell.swift
//  EssentialFeediOS
//
//  Created by Maxim Soldatov on 11/29/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedImageCommentCell: UITableViewCell {
	
	@IBOutlet public private(set) weak var usernameLabel: UILabel?
	@IBOutlet public private(set) weak var creationTimeLabel: UILabel?
	@IBOutlet public private(set) weak var commentLabel: UILabel?
	
	func display(_ viewModel: FeedImageCommentPresentingModel) {
		usernameLabel?.text = viewModel.username
		creationTimeLabel?.text = viewModel.creationTime
		commentLabel?.text = viewModel.comment
	}
	
}

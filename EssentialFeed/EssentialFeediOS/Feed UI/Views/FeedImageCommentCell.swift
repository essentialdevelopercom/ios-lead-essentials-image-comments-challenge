//
//  FeedImageCommentCell.swift
//  EssentialFeediOS
//
//  Created by Ivan Ornes on 15/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public final class FeedImageCommentCell: UITableViewCell {
	@IBOutlet private(set) public var messageLabel: UILabel!
	@IBOutlet private(set) public var createdAtLabel: UILabel!
	@IBOutlet private(set) public var authorLabel: UILabel!
}

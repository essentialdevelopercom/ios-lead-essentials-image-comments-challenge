//
//  ImageCommentCell.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public final class ImageCommentCell: UITableViewCell {
	@IBOutlet private(set) public var messageLabel: UILabel!
	@IBOutlet private(set) public var authorNameLabel: UILabel!
	@IBOutlet private(set) public var createdAtLabel: UILabel!
}

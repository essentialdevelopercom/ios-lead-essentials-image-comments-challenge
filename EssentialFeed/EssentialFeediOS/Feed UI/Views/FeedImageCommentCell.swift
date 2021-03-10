//
//  CommentCell.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 05.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public final class CommentCell: UITableViewCell {
	@IBOutlet private(set) public var authorLabel: UILabel!
	@IBOutlet private(set) public var dateLabel: UILabel!
	@IBOutlet private(set) public var commentLabel: UILabel!
}

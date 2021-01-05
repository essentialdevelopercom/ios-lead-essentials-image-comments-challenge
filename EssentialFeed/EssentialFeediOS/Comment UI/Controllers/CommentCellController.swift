//
//  CommentCellController.swift
//  EssentialFeediOS
//
//  Created by Khoi Nguyen on 5/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import UIKit
import EssentialFeed

final class CommentCellController {
	private let model: PresentableComment
	
	init(model: PresentableComment) {
		self.model = model
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
		cell.authorLabel?.text = model.author
		cell.timestampLabel?.text = model.createAt
		cell.commentLabel?.text = model.message
		
		return cell
	}
}

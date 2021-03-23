//
//  ImageCommentsCellController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

final class ImageCommentsCellController {
	private let model: ImageComment
	private let currentDate: () -> Date
	
	init(model: ImageComment, currentDate: @escaping () -> Date) {
		self.model = model
		self.currentDate = currentDate
	}
	
	func view() -> UITableViewCell {
		let cell = ImageCommentCell()
		cell.authorLabel.text = model.author
		cell.messageLabel.text = model.message
		cell.creationDateLabel.text = formatRelativeDate(for: model.creationDate)
		return cell
	}
	
	private func formatRelativeDate(for date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		return formatter.localizedString(for: date, relativeTo: currentDate())
	}
}

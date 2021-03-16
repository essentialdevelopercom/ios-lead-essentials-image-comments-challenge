//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentCellController {
	private var cell: ImageCommentCell?
	private let viewModel: () -> ImageCommentViewModel
	private let relativeDate: () -> Date
	
	public init(viewModel: @escaping () -> ImageCommentViewModel, relativeDate: @escaping () -> Date) {
		self.viewModel = viewModel
		self.relativeDate = relativeDate
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		display(viewModel())
		return cell!
	}
	
	private func display(_ viewModel: ImageCommentViewModel) {
		cell?.authorLabel.text = viewModel.authorUsername
		cell?.messageLabel.text = viewModel.body
		cell?.relativeDateLabel.text = localizedDate(date: viewModel.date)
	}
	
	private func localizedDate(date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		return formatter.localizedString(for: date, relativeTo: relativeDate())
	}
}

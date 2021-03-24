//
//  ImageCommentPresenter.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 23/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

struct ImageCommentViewModel {
	let author: String
	let message: String
	let creationDate: String
}

protocol ImageCommentView {
	func display(_ viewModel: ImageCommentViewModel)
}

final class ImageCommentPresenter {
	private let currentDate: () -> Date
	private let commentView: ImageCommentView
	
	init(currentDate: @escaping () -> Date, commentView: ImageCommentView) {
		self.currentDate = currentDate
		self.commentView = commentView
	}
	
	func didLoadComment(_ comment: ImageComment) {
		commentView.display(
			ImageCommentViewModel(
				author: comment.author,
				message: comment.message,
				creationDate: formatRelativeDate(for: comment.creationDate)
			)
		)
	}
	
	private func formatRelativeDate(for date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		return formatter.localizedString(for: date, relativeTo: currentDate())
	}
}

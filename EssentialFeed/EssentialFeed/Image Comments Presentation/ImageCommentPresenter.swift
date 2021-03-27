//
//  ImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Ángel Vázquez on 27/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

// MARK: - ViewModels

public struct ImageCommentViewModel {
	public let author: String
	public let message: String
	public let creationDate: String
}

// MARK: - View Protocols

public protocol ImageCommentView {
	func display(_ viewModel: ImageCommentViewModel)
}

// MARK: - ImageCommentPresenter

public final class ImageCommentPresenter {
	private let currentDate: () -> Date
	private let commentView: ImageCommentView
	
	public init(currentDate: @escaping () -> Date, commentView: ImageCommentView) {
		self.currentDate = currentDate
		self.commentView = commentView
	}
	
	public func didLoadComment(_ comment: ImageComment) {
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

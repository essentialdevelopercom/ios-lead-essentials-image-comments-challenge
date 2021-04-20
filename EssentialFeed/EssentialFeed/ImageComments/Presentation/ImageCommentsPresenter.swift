//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 27.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsPresenter {
	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the comments view"
		)
	}

	public static func map(_ imageComments: [ImageComment]) -> ImageCommentsViewModel {
		let formatter = RelativeDateTimeFormatter()

		return ImageCommentsViewModel(imageComments: imageComments.map { comment in
			ImageCommentViewModel(
				message: comment.message,
				username: comment.username,
				createdAt: formatter.localizedString(for: comment.createdAt, relativeTo: Date())
			)
		})
	}
}
//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 4/24/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsPresenter {
	public static var title: String {
		NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: Self.self),
			comment: "Title for the image comments view")
	}
}

//
//  ImageCommentsViewModel.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 19/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct ImageCommentsViewModel {
	public let comments: [ImageComment]
}

extension ImageCommentsViewModel {
	public static func comments(
		_ comments: [ImageComment]
	) -> ImageCommentsViewModel {
		ImageCommentsViewModel(comments: comments)
	}
}

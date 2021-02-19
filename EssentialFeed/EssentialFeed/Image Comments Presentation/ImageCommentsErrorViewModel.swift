//
//  ImageCommentsErrorViewModel.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 19/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct ImageCommentsErrorViewModel {
	public let message: String?
}

extension ImageCommentsErrorViewModel {
	public static var noError: ImageCommentsErrorViewModel {
		ImageCommentsErrorViewModel(message: nil)
	}

	public static func error(
		message: String
	) -> ImageCommentsErrorViewModel {
		ImageCommentsErrorViewModel(message: message)
	}
}

//
//  ImageCommentErrorViewModel.swift
//  EssentialFeed
//
//  Created by Cronay on 20.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsErrorViewModel {
	public let message: String?

	static var noError: ImageCommentsErrorViewModel {
		return ImageCommentsErrorViewModel(message: nil)
	}

	static func error(message: String) -> ImageCommentsErrorViewModel {
		return ImageCommentsErrorViewModel(message: message)
	}

}

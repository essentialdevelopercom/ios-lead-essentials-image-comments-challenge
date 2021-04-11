//
//  ImageCommentsErrorViewModel.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct ImageCommentsErrorViewModel {
	public let message: String?

	static var noError: ImageCommentsErrorViewModel {
		return ImageCommentsErrorViewModel(message: nil)
	}

	static func error(message: String) -> ImageCommentsErrorViewModel {
		return ImageCommentsErrorViewModel(message: message)
	}
}

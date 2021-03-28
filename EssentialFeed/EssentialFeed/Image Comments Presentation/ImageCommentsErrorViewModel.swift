//
//  ImageCommentsErrorViewModel.swift
//  EssentialFeed
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsErrorViewModel {
	public let message: String?
	
	public static var noError: ImageCommentsErrorViewModel {
		return ImageCommentsErrorViewModel(message: nil)
	}

	public static func error(message: String) -> ImageCommentsErrorViewModel {
		return ImageCommentsErrorViewModel(message: message)
	}
	
	public init(message: String?) {
		self.message = message
	}
}

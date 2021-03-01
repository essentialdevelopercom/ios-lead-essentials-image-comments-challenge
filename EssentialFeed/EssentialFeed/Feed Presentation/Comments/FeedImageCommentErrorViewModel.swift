//
//  FeedImageCommentErrorViewModel.swift
//  EssentialFeed
//
//  Created by Danil Vassyakin on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageCommentErrorViewModel {
	public let message: String?
	
	public static var noError: Self {
		Self(message: nil)
	}
	
	public static func error(message: String) -> Self {
		Self(message: message)
	}
}

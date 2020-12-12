//
//  FeedImageCommentErrorViewModel.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import Foundation

public struct FeedImageCommentErrorViewModel {
	
	public let message: String?
	
	public static var noError: FeedImageCommentErrorViewModel {
		return FeedImageCommentErrorViewModel(message: nil)
	}
	
	public static func error(message:String) -> FeedImageCommentErrorViewModel {
		return FeedImageCommentErrorViewModel(message: message)
	}
}


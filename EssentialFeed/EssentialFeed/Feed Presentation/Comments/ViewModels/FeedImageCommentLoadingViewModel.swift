//
//  FeedImageCommentLoadingViewModel.swift
//  EssentialFeed
//
//  Created by Danil Vassyakin on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageCommentLoadingViewModel {
	public let isLoading: Bool
}

public extension FeedImageCommentLoadingViewModel {
	
	static var loading: Self {
		Self(isLoading: true)
	}
	
	static var notLoading: Self {
		Self(isLoading: false)
	}
	
}

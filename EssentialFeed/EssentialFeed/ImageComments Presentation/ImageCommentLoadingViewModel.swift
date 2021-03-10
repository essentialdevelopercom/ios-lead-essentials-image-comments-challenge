//
//  ImageCommentLoadingViewModel.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/10/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct ImageCommentLoadingViewModel {
	public let isLoading: Bool
	
	static var loading: ImageCommentLoadingViewModel {
		return ImageCommentLoadingViewModel(isLoading: true)
	}
	static var finished: ImageCommentLoadingViewModel {
		return ImageCommentLoadingViewModel(isLoading: false)
	}
}

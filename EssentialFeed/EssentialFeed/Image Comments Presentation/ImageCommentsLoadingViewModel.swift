//
//  ImageCommentsLoadingViewModel.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 19/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct ImageCommentsLoadingViewModel {
	public let isLoading: Bool
}

extension ImageCommentsLoadingViewModel {
	public static var loading: ImageCommentsLoadingViewModel {
		ImageCommentsLoadingViewModel(isLoading: true)
	}

	public static var notLoading: ImageCommentsLoadingViewModel {
		ImageCommentsLoadingViewModel(isLoading: false)
	}
}

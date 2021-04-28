//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 4/24/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct ResourceErrorViewModel {
	public let message: String?

	static var noError: ResourceErrorViewModel {
		return ResourceErrorViewModel(message: nil)
	}

	static func error(message: String) -> ResourceErrorViewModel {
		return ResourceErrorViewModel(message: message)
	}
}

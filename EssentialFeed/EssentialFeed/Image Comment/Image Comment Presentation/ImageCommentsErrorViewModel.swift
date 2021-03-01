//
//  ImageCommentsErrorViewModel.swift
//  EssentialFeed
//
//  Created by Alok Subedi on 03/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsErrorViewModel {
	public let message: String?
	
	public init(message: String?) {
		self.message = message
	}
}

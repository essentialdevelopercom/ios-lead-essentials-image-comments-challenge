//
//  ImageCommentsErrorViewModel.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 25/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsErrorViewModel{
	public let message: String?
	
	static var noError: ImageCommentsErrorViewModel {
		return ImageCommentsErrorViewModel(message: nil)
	}
}

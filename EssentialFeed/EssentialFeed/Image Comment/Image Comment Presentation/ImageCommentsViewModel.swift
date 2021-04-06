//
//  ImageCommentsViewModel.swift
//  EssentialFeed
//
//  Created by Alok Subedi on 03/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsViewModel {
	public let comments: [PresentableImageComment]
	
	public init(comments: [PresentableImageComment]) {
		self.comments = comments
	}
}


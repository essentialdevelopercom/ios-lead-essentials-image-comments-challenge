//
//  FeedCommentViewModel.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 14/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class FeedImageCommentCellViewModel {
	private let model: FeedImageComment
	
	public init(model: FeedImageComment) {
		self.model = model
	}
	
	public var message: String? {
		return model.message
	}
	
	public var authorName: String?  {
		return model.author
	}
}

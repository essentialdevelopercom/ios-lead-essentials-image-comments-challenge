//
//  ImageCommentViewModel.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

final class ImageCommentViewModel {
	let model: ImageComment
	private lazy var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		df.timeStyle = .medium
		return df
	}()

	var message: String? {
		model.message
	}

	var author: String? {
		model.author.username
	}

	var createdAt: String? {
		dateFormatter.string(from: model.createdAt)
	}

	init(model: ImageComment) {
		self.model = model
	}
}

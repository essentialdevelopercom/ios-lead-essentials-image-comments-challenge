//
//  ImageCommentsViewModel.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed

final class ImageCommentsViewModel {
	private let imageCommentsLoader: ImageCommentsLoader

	init(imageCommentsLoader: ImageCommentsLoader) {
		self.imageCommentsLoader = imageCommentsLoader
	}

	var onChange: ((ImageCommentsViewModel) -> Void)?
	var onImageCommentsLoad: (([ImageComment]) -> Void)?

	private(set) var isLoading: Bool = false {
		didSet {
			onChange?(self)
		}
	}

	func loadImageComments() {
		isLoading = true
		imageCommentsLoader.load { [weak self] result in
			if let imageComments = try? result.get() {
				self?.onImageCommentsLoad?(imageComments)
			}
			self?.isLoading = false
		}
	}
}

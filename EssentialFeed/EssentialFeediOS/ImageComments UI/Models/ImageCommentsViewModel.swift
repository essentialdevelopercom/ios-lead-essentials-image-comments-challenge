//
//  ImageCommentsViewModel.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed

final class ImageCommentsViewModel {
	typealias Observer<T> = (T) -> Void

	private let imageCommentsLoader: ImageCommentsLoader

	init(imageCommentsLoader: ImageCommentsLoader) {
		self.imageCommentsLoader = imageCommentsLoader
	}

	var onLoadingStateChange: Observer<Bool>?
	var onImageCommentsLoad: Observer<[ImageComment]>?

	func loadImageComments() {
		onLoadingStateChange?(true)
		imageCommentsLoader.load { [weak self] result in
			if let imageComments = try? result.get() {
				self?.onImageCommentsLoad?(imageComments)
			}
			self?.onLoadingStateChange?(false)
		}
	}
}

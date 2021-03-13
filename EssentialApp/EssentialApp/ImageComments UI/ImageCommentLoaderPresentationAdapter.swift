//
//  ImageCommentLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Eric Garlock on 3/13/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

class ImageCommentLoaderPresentationAdapter : ImageCommentsViewControllerDelegate {
	
	public var loader: ImageCommentLoader
	public var presenter: ImageCommentPresenter?
	
	public init(loader: ImageCommentLoader) {
		self.loader = loader
	}
	
	public func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingComments()
		loader.load { [weak self] result in
			switch result {
			case let .success(imageComments):
				self?.presenter?.didFinishLoadingComments(with: imageComments)
				break
			case let .failure(error):
				self?.presenter?.didFinishLoadingComments(with: error)
				break
			}
		}
	}
	
}

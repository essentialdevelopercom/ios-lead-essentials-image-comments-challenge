//
//  ImageCommentsPresentationAdapter.swift
//  EssentialApp
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS

final class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	let imageLoader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	private var task: ImageCommmentsLoaderTask?
	
	init(imageLoader: ImageCommentsLoader) {
		self.imageLoader = imageLoader
	}
	
	func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingComments()
		
		task = imageLoader.loadImageComments { [presenter] result in
			switch result {
			case let .success(comments):
				presenter?.didFinishLoadingComments(with: comments)
				
			case let .failure(error):
				presenter?.didFinishLoadingComments(with: error)
			}
		}
	}
	
	func didCancelImageCommentsLoading() {
		task?.cancel()
	}
	
}

//
//  ImageCommentsPresentationAdapter.swift
//  EssentialApp
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	let imageLoader: ImageCommentsLoader
	let relativeDate: () -> Date
	
	var presenter: ImageCommentsPresenter?
	private var task: ImageCommmentsLoaderTask?
	
	init(imageLoader: ImageCommentsLoader, relativeDate: @escaping () -> Date) {
		self.imageLoader = imageLoader
		self.relativeDate = relativeDate
	}
	
	func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingComments()
		
		task = imageLoader.loadImageComments { [presenter, relativeDate] result in
			switch result {
			case let .success(comments):
				presenter?.didFinishLoadingComments(with: comments, relativeDate: relativeDate)
				
			case let .failure(error):
				presenter?.didFinishLoadingComments(with: error)
			}
		}
	}
	
	func didCancelImageCommentsLoading() {
		task?.cancel()
	}
	
}

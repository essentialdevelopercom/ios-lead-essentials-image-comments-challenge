//
//  ImageCommentsLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Bogdan Poplauschi on 02/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import Foundation

final class ImageCommentsLoaderPresentationAdapter: ImageCommentsViewControllerDelegate {
	private let loader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	private var task: ImageCommentsLoaderTask?
	
	init(loader: ImageCommentsLoader) {
		self.loader = loader
	}
	
	deinit {
		task?.cancel()
	}
	
	func didRequestCommentsRefresh() {
		presenter?.didStartLoadingComments()
		
		task = loader.load { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case let .success(comments):
				self.presenter?.didFinishLoading(with: comments)
				
			case let .failure(error):
				self.presenter?.didFinishLoading(with: error)
			}
		}
	}	
}

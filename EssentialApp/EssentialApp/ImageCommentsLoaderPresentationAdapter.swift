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

public final class ImageCommentsLoaderPresentationAdapter: ImageCommentsViewControllerDelegate {
	private let loader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	private var task: ImageCommentsLoaderTask?
	
	public init(loader: ImageCommentsLoader) {
		self.loader = loader
	}
	
	public func didRequestCommentsRefresh() {
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
	
	public func didCancelCommentsRequest() {
		task?.cancel()
	}
}

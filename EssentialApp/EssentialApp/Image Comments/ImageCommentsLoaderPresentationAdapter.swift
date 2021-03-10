//
//  ImageCommentsLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Lukas Bahrle Santana on 05/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

final class ImageCommentsLoaderPresentationAdapter: ImageCommentsControllerDelegate {
	let loader: () -> ImageCommentsLoader.Publisher
	var presenter: ImageCommentsPresenter?
	
	private var cancellable: Cancellable?
	
	private var loaderTask:ImageCommentsLoaderTask?
	
	init(imageCommentsLoader: @escaping () -> ImageCommentsLoader.Publisher){
		self.loader = imageCommentsLoader
	}
	
	deinit {
		cancellable?.cancel()
	}
	
	func didRequestImageCommentsRefresh() {
		self.presenter?.didStartLoadingImageComments()
		
		cancellable = loader()
			.dispatchOnMainQueue()
			.sink(receiveCompletion: { [weak self] completion in
				switch completion {
				case .finished: break
				case let .failure(error):
				self?.presenter?.didFinishLoadingImageComments(with: error)
				}
			}, receiveValue: { [weak self] imageComments in
				self?.presenter?.didFinishLoadingImageComments(with: imageComments)
			})
	}
	
	func didRequestImageCommentsCancel() {
		cancellable?.cancel()
	}
	
	
}

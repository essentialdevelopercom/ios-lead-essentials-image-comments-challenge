//
//  ImageCommentsLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Araceli Ruiz Ruiz on 08/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import Combine
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsLoaderPresentationAdapter: ImageCommentsViewControllerDelegate {
    var presenter: ImageCommentsPresenter?
	private var task: ImageCommentsLoaderTask?
    
    private let url: URL
	private let imageCommentsLoader: ImageCommentsLoader

    init(url: URL, imageCommentsLoader: ImageCommentsLoader) {
        self.url = url
        self.imageCommentsLoader = imageCommentsLoader
    }
    
    func didRequestCommentsRefresh() {
        presenter?.didStartLoadingComments()
		task = imageCommentsLoader.loadComments(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingComments(with: comments)
			case let .failure(error):
				self?.presenter?.didFinishLoadingComments(with: error)
			}
		}

                
//        let cancellable = imageCommentsLoader(url)
//            .dispatchOnMainQueue()
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    switch completion {
//                    case .finished:
//                        break
//                    case let .failure(error):
//                        self?.presenter?.didFinishLoadingComments(with: error)
//                    }
//
//                }, receiveValue: { [weak self] comments in
//                    self?.presenter?.didFinishLoadingComments(with: comments)
//                })
//
//        self.cancellable = cancellable
    }
    
    deinit {
        task?.cancel()
        task = nil
    }
}

//
//  ImageCommentsLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Araceli Ruiz Ruiz on 08/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS

final class ImageCommentsLoaderPresentationAdapter: ImageCommentsViewControllerDelegate {
    var presenter: ImageCommentsPresenter?
    private var task: ImageCommentsLoaderTask?
    
    private let imageCommentsLoader: ImageCommentsLoader
    
    init(imageCommentsLoader: ImageCommentsLoader) {
        self.imageCommentsLoader = imageCommentsLoader
    }
    
    func didRequestCommentsRefresh() {
        presenter?.didStartLoadingComments()
        task = imageCommentsLoader.loadComments { [weak self] result in
            switch result {
            case let .success(comments):
                self?.presenter?.didFinishLoadingComments(with: comments)
            case let .failure(error):
                self?.presenter?.didFinishLoadingComments(with: error)
            }
        }
    }
    
    func didRequestCancelLoad() {
        task?.cancel()
        task = nil
    }
}

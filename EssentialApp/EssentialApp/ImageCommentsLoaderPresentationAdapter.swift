//
//  ImageCommentsLoaderPresentationAdapter.swift
//  EssentialApp
//
//  Created by Araceli Ruiz Ruiz on 08/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS

final class ImageCommentsLoaderPresentationAdapter: ImageCommentsRefreshControllerDelegate {
    private let imageCommentsLoader: ImageCommentsLoader
    private let presenter: ImageCommentsPresenter
    
    private var task: ImageCommentsLoaderTask?
    
    init(imageCommentsLoader: ImageCommentsLoader, presenter: ImageCommentsPresenter) {
        self.imageCommentsLoader = imageCommentsLoader
        self.presenter = presenter
    }
    
    func didRequestCommentsRefresh() {
        presenter.didStartLoadingComments()
        task = imageCommentsLoader.loadComments { [weak self] result in
            switch result {
            case let .success(comments):
                self?.presenter.didFinishLoadingComments(with: comments)
            case let .failure(error):
                self?.presenter.didFinishLoadingComments(with: error)
            }
        }
    }
    
    func didRequestCancelLoad() {
        task?.cancel()
        task = nil
    }
}

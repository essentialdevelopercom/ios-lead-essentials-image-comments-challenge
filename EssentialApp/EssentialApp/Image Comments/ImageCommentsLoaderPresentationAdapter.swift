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
    private var cancellable: Cancellable?
    
    private let url: URL
    private let imageCommentsLoader: (URL) -> ImageCommentsLoader.Publisher
    
    init(url: URL, imageCommentsLoader: @escaping (URL) -> ImageCommentsLoader.Publisher) {
        self.url = url
        self.imageCommentsLoader = imageCommentsLoader
    }
    
    func didRequestCommentsRefresh() {
        presenter?.didStartLoadingComments()
                
        let cancellable = imageCommentsLoader(url)
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        self?.presenter?.didFinishLoadingComments(with: error)
                    }
                    
                }, receiveValue: { [weak self] comments in
                    self?.presenter?.didFinishLoadingComments(with: comments)
                })
        
        self.cancellable = cancellable
    }
    
    func didRequestCancelLoad() {
        cancellable?.cancel()
        cancellable = nil
    }
}

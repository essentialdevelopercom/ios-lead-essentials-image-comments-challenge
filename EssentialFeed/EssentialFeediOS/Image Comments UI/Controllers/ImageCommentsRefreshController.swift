//
//  ImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol ImageCommentsRefreshControllerDelegate {
    func didRequestCommentsRefresh()
    func didRequestCancelLoad()
}

public final class ImageCommentsRefreshController: NSObject, ImageCommentsView, ImageCommentsLoadingView {
    @IBOutlet private var view: UIRefreshControl?
            
    public var onRefresh: (([ImageComment]) -> Void)?
    
    public var delegate: ImageCommentsRefreshControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestCommentsRefresh()
    }
    
    func cancelLoad() {
        delegate?.didRequestCancelLoad()
    }
    
    public func display(_ viewModel: ImageCommentsViewModel) {
        onRefresh?(viewModel.comments)
    }
    
    public func display(_ viewModel: ImageCommentsLoadingViewModel) {
        view?.update(isRefreshing: viewModel.isLoading)
    }
}

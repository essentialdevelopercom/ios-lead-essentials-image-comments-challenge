//
//  ImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final class ImageCommentsRefreshController: NSObject {
    private var task: ImageCommentsLoaderTask?
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let loader: ImageCommentsLoader
    
    init(loader: ImageCommentsLoader) {
        self.loader = loader
    }
    
    var onRefresh: (([ImageComment]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        task = loader.loadComments { [weak self] result in
            if let imageComments = try? result.get() {
                self?.onRefresh?(imageComments)
            }
            self?.view.endRefreshing()
        }
    }
    
    func cancelLoad() {
        task?.cancel()
        task = nil
    }
}

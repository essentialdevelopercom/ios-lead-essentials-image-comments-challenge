//
//  ImageCommentsRefreshController.swift
//  EssentialFeediOS
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentsRefreshController: NSObject {
    private var task: ImageCommentsLoaderTask?
    
    @IBOutlet private var view: UIRefreshControl?
        
    public var loader: ImageCommentsLoader?
    
    public var onRefresh: (([ImageComment]) -> Void)?
    
    @IBAction func refresh() {
        view?.beginRefreshing()
        task = loader?.loadComments { [weak self] result in
            if let imageComments = try? result.get() {
                self?.onRefresh?(imageComments)
            }
            self?.view?.endRefreshing()
        }
    }
    
    func cancelLoad() {
        task?.cancel()
        task = nil
    }
}

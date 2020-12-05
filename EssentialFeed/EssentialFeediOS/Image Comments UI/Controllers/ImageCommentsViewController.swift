//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Araceli Ruiz Ruiz on 29/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentsViewController: UITableViewController {
    private var tableModel = [ImageCommentCellController]()
    private var refreshController: ImageCommentsRefreshController?
    
    public convenience init(loader: ImageCommentsLoader) {
        self.init()
        self.refreshController = ImageCommentsRefreshController(loader: loader)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ImageCommentCell.self, forCellReuseIdentifier: "ImageCommentCell")
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] imageComments in
            self?.tableModel = imageComments.map { ImageCommentCellController(model: $0) }
            self?.tableView.reloadData()
        }
        refreshController?.refresh()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        refreshController?.cancelLoad()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableModel[indexPath.row].view(in: tableView)
    }
}

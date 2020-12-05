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
    private var tableModel = [ImageComment]()
    
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
            self?.tableModel = imageComments
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
        let cellModel = tableModel[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell") as! ImageCommentCell
        cell.author.text = cellModel.username
        cell.date.text = cellModel.createdAt.relativeDate(to: Date())
        cell.message.text = cellModel.message
        return cell
    }
}

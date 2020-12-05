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
    private var loader: ImageCommentsLoader?
    private var tableModel = [ImageComment]()
    private var task: ImageCommentsLoaderTask?
    
    public convenience init(loader: ImageCommentsLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.register(ImageCommentCell.self, forCellReuseIdentifier: "ImageCommentCell")
        load()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelLoad()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        task = loader?.loadComments() { [weak self] result in
            switch result {
            case let .success(comments):
                self?.tableModel = comments
                self?.tableView.reloadData()
            case .failure:
                break
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    func cancelLoad() {
        task?.cancel()
        task = nil
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

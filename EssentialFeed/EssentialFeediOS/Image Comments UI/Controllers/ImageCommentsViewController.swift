//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Araceli Ruiz Ruiz on 29/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentsViewController: UITableViewController, ImageCommentsErrorView {
    public var tableModel = [ImageCommentCellController]()
    @IBOutlet private(set) public var errorView: ErrorView?
    @IBOutlet public var refreshController: ImageCommentsRefreshController?
    
    public convenience init(refreshController: ImageCommentsRefreshController) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshController?.refresh()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        refreshController?.cancelLoad()
    }
    
    public func display(_ viewModel: ImageCommentsErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableModel[indexPath.row].view(in: tableView)
    }
}

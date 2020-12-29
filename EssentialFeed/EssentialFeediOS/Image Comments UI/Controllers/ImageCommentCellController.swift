//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentCellController {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.author.text = model.username
        cell.date.text = model.date
        cell.message.text = model.message
        return cell
    }
}

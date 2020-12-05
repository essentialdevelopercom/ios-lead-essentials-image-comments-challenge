//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final class ImageCommentCellController {
    private let model: ImageComment
    private var cell: ImageCommentCell?
    
    init(model: ImageComment) {
        self.model = model
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.author.text = model.username
        cell?.date.text = model.createdAt.relativeDate()
        cell?.message.text = model.message
        return cell!
    }
}

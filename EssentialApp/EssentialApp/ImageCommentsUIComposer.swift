//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS

public final class ImageCommentsUIComposer {
    public static func imageCommentsComposedWith(loader: ImageCommentsLoader) -> ImageCommentsViewController {
        let refreshController = ImageCommentsRefreshController(loader: loader)
        let imageCommentsViewController = ImageCommentsViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak imageCommentsViewController] imageComments in
            imageCommentsViewController?.tableModel = imageComments.map { ImageCommentCellController(model: $0) }
            imageCommentsViewController?.tableView.reloadData()
        }
        return imageCommentsViewController
    }
}

//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class ImageCommentsUIComposer {
    public static func imageCommentsComposedWith(loader: ImageCommentsLoader) -> ImageCommentsViewController {
        let bundle = Bundle(for: ImageCommentsViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let imageCommentsViewController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
        let refreshController = imageCommentsViewController.refreshController!
        
        let presenter = ImageCommentsPresenter(
            imageCommentsView: WeakRefVirtualProxy(refreshController),
            loadingView: WeakRefVirtualProxy(refreshController),
            errorView: WeakRefVirtualProxy(imageCommentsViewController)
        )
        
        let adapter = ImageCommentsLoaderPresentationAdapter(imageCommentsLoader: loader, presenter: presenter)

        
        refreshController.delegate = adapter

        refreshController.onRefresh = { [weak imageCommentsViewController] imageComments in
            imageCommentsViewController?.tableModel = imageComments.map { ImageCommentCellController(model: $0) }
            imageCommentsViewController?.tableView.reloadData()
        }
        
        
        return imageCommentsViewController
    }
}

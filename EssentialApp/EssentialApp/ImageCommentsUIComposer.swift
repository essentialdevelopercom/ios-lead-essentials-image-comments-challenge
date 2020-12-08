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
        
        let presenter = ImageCommentsPresenter(
            imageCommentsView: WeakRefVirtualProxy(imageCommentsViewController),
            loadingView: WeakRefVirtualProxy(imageCommentsViewController),
            errorView: WeakRefVirtualProxy(imageCommentsViewController)
        )
        
        let adapter = ImageCommentsLoaderPresentationAdapter(imageCommentsLoader: loader, presenter: presenter)

        
        imageCommentsViewController.delegate = adapter
        
        return imageCommentsViewController
    }
}

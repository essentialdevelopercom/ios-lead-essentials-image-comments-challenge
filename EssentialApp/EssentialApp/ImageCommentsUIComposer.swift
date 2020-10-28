//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import Foundation
import UIKit

public final class ImageCommentsUIComposer {
    public static func imageCommentsComposeWith(
        commentsLoader: ImageCommentsLoader,
        url: URL,
        date: Date
    ) -> ImageCommentsViewController {
        let bundle = Bundle(for: ImageCommentsViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let commentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
        let presentationAdapter = ImageCommentsPresentationAdapter(loader: commentsLoader, url: url)
        commentsController.delegate = presentationAdapter
        let presenter = ImageCommentsPresenter(
            imageCommentsView: WeakRefVirtualProxy(commentsController),
            loadingView: WeakRefVirtualProxy(commentsController),
            errorView: WeakRefVirtualProxy(commentsController),
            currentDate: date
        )
        presentationAdapter.presenter = presenter
        return commentsController
    }
}

public final class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
    var presenter: ImageCommentsPresenter?
    let loader: ImageCommentsLoader
    let url: URL

    public init(loader: ImageCommentsLoader, url: URL) {
        self.loader = loader
        self.url = url
    }

    public func didRequestCommentsRefresh() {
        presenter?.didStartLoadingComments()
        _ = loader.load(from: url) { [weak self] result in
            switch result {
            case let .success(comments):
                self?.presenter?.didFinishLoading(with: comments)
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }
}

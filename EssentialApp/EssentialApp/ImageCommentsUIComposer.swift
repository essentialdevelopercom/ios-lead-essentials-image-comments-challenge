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
        let presentationAdapter = ImageCommentsPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: commentsLoader), url: url)
        let commentsController = makeController(delegate: presentationAdapter)
        let presenter = ImageCommentsPresenter(
            imageCommentsView: WeakRefVirtualProxy(commentsController),
            loadingView: WeakRefVirtualProxy(commentsController),
            errorView: WeakRefVirtualProxy(commentsController),
            currentDate: date
        )
        presentationAdapter.presenter = presenter
        return commentsController
    }

    private static func makeController(delegate: ImageCommentsViewControllerDelegate) -> ImageCommentsViewController {
        let bundle = Bundle(for: ImageCommentsViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
        controller.title = ImageCommentsPresenter.title
        controller.delegate = delegate
        return controller
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

public final class MainQueueDispatchDecorator: ImageCommentsLoader {
    let decoratee: ImageCommentsLoader

    init(decoratee: ImageCommentsLoader) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { completion() }
        }
        completion()
    }

    public func load(from url: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
        decoratee.load(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

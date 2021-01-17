//
//  Created by Flavio Serrazes on 15.01.21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedImageCommentsUIComposer {
    public static func imageCommentsComposeWith(commentsLoader: FeedImageCommentsLoader, url: URL) -> FeedImageCommentsViewController {
        let presentationAdapter = FeedImageCommentsPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: commentsLoader), url: url)
        let viewController = makeController(delegate: presentationAdapter)
        let presenter = FeedImageCommentsPresenter(
            commentsView: WeakRefVirtualProxy(viewController),
            loadingView: WeakRefVirtualProxy(viewController),
            errorView: WeakRefVirtualProxy(viewController)
        )
        presentationAdapter.presenter = presenter

        return viewController
    }

    private static func makeController(delegate: FeedImageCommentsViewControllerDelegate) -> FeedImageCommentsViewController {
        let bundle = Bundle(for: FeedImageCommentsViewController.self)
        let storyboard = UIStoryboard(name: "FeedImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedImageCommentsViewController
        controller.delegate = delegate
        controller.title = FeedImageCommentsPresenter.title
        return controller
    }
}

public final class FeedImageCommentsPresentationAdapter: FeedImageCommentsViewControllerDelegate {
    var presenter: FeedImageCommentsPresenter?
    let loader: FeedImageCommentsLoader
    let url: URL
    
    init(loader: FeedImageCommentsLoader, url: URL) {
        self.loader = loader
        self.url = url
    }
    
    public func didRequestCommentsRefresh() {
        presenter?.didStartLoadingComments()
        
        _ = loader.load(from: url) { [weak self] result in
            switch result {
            case let .success(comments):
                self?.presenter?.didFinishLoadingComments(with: comments)
                
                case let .failure(error):
                    self?.presenter?.didFinishLoadingComments(with: error)
            }
        }
    }
}

public final class MainQueueDispatchDecorator: FeedImageCommentsLoader {
     let decoratee: FeedImageCommentsLoader

     init(decoratee: FeedImageCommentsLoader) {
         self.decoratee = decoratee
     }

     func dispatch(completion: @escaping () -> Void) {
         guard Thread.isMainThread else {
             return DispatchQueue.main.async { completion() }
         }
         completion()
     }

     public func load(from url: URL, completion: @escaping (FeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
         decoratee.load(from: url) { [weak self] result in
             self?.dispatch { completion(result) }
         }
     }
 }

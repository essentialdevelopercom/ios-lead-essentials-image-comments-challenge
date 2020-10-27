//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import XCTest

class ImageCommentsUIComposer {
    static func imageCommentsComposeWith(commentsLoader: ImageCommentsLoader, url: URL) -> ImageCommentsViewController {
        let bundle = Bundle(for: ImageCommentsViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let commentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
        let presentationAdapter = ImageCommentsPresentationAdapter(loader: commentsLoader, url: url)
        commentsController.delegate = presentationAdapter
        let presenter = ImageCommentsPresenter(
            imageCommentsView: commentsController,
            loadingView: commentsController,
            errorView: commentsController
        )
        presentationAdapter.presenter = presenter
        return commentsController
    }
}

class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
    var presenter: ImageCommentsPresenter?
    let loader: ImageCommentsLoader
    let url: URL

    init(loader: ImageCommentsLoader, url: URL) {
        self.loader = loader
        self.url = url
    }

    func didRequestCommentsRefresh() {
        presenter?.didStartLoadingComments()
        _ = loader.load(from: url) { result in
            switch result {
            case let .success(comments):
                self.presenter?.didFinishLoading(with: comments)
            case let .failure(error):
                self.presenter?.didFinishLoading(with: error)
            }
        }
    }
}

final class ImageCommentsUIIntegrationTests: XCTestCase {
    func test_loadCommentsAction_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }

    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")

        loader.completeCommentsLoading()
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user initiates a reload")

        loader.completeCommentsLoading(with: anyNSError())
        XCTAssertEqual(
            sut.isShowingLoadingIndicator,
            false,
            "Expected no loading indicator once user initiated loading completes with error"
        )
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "http://any-url.com")!,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> (ImageCommentsViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let controller = ImageCommentsUIComposer.imageCommentsComposeWith(commentsLoader: loader, url: url)
        return (controller, loader)
    }

    private class LoaderSpy: ImageCommentsLoader {
        var loadCommentsCallCount: Int { completions.count }
        var completions = [(ImageCommentsLoader.Result) -> Void]()

        private struct Task: ImageCommentsLoaderTask {
            func cancel() {}
        }

        func load(from _: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
            completions.append(completion)
            return Task()
        }

        func completeCommentsLoading(at index: Int = 0) {
            completions[index](.success([]))
        }

        func completeCommentsLoading(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}

extension ImageCommentsViewController {
    func simulateUserInitiatedCommentsReload() {
        refreshControl?.simulatePullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}

//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Araceli Ruiz Ruiz on 21/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsViewController: UITableViewController {
    private var loader: ImageCommentsLoader?
    private var tableModel = [ImageComment]()
    
    convenience init(loader: ImageCommentsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        _ = loader?.loadComments() { [weak self] result in
            switch result {
            case let .success(comments):
                self?.tableModel = comments
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            case .failure:
                break
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = ImageCommentCell()
        cell.author.text = cellModel.username
        cell.date.text = cellModel.createdAt.relativeDate(to: Date())
        cell.message.text = cellModel.message
        return cell
    }
}

final class ImageCommentsViewControllerTests: XCTestCase {

    func test_init_doesNotLoadComments() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallsCount, 0)
    }
    
    func test_loadCommentsActions_requestCommentsfromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallsCount, 0, "Expected no loading requests before view is loaded")
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallsCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(loader.loadCallsCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(loader.loadCallsCount, 3, "Expected yet another loading request once user initiates another")
    }
  
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        
        sut.simulateUserInitiatedCommentsReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeCommentsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = ImageComment(id: UUID(), message: "message0", createdAt: Date(), username: "username0")
        let comment1 = ImageComment(id: UUID(), message: "message1", createdAt: Date(), username: "username1")
        let comment2 = ImageComment(id: UUID(), message: "message2", createdAt: Date(), username: "username2")
        let comment3 = ImageComment(id: UUID(), message: "message3", createdAt: Date(), username: "username3")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        let comments = [comment0, comment1, comment2, comment3]
        sut.simulateUserInitiatedCommentsReload()
        loader.completeCommentsLoading(with: comments, at: 1)
        
        assertThat(sut, isRendering: comments)
    }
    
    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment0 = ImageComment(id: UUID(), message: "message0", createdAt: Date(), username: "username0")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedCommentsReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment0])
    }
    

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, client: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ImageCommentsViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: ImageCommentsViewController, isRendering comments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
       guard sut.numberOfRenderedImageComments() == comments.count else {
            return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedImageComments()) instead.", file: file, line: line)
        }

        comments.enumerated().forEach { index, comment in
            assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor comment: ImageComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.comment(at: index)

        guard let cell = view as? ImageCommentCell else {
            return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        XCTAssertEqual(cell.author.text, comment.username, "Expected username text to be \(String(describing: comment.username)) for comment at index (\(index))", file: file, line: line)

        XCTAssertEqual(cell.date.text, comment.createdAt.relativeDate(), "Expected relative date text to be \(String(describing: comment.createdAt.relativeDate())) for comment at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.message.text, comment.message, "Expected message text to be \(String(describing: comment.message)) for comment at index (\(index))", file: file, line: line)
    }
 
    class LoaderSpy: ImageCommentsLoader {
        private var completions = [(ImageCommentsLoader.Result) -> Void]()
        
        var loadCallsCount: Int {
            completions.count
        }

        private struct TaskSpy: ImageCommentsLoaderTask {
            func cancel() {}
        }
        
        func loadComments(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
            completions.append(completion)
            return TaskSpy()
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int) {
            completions[index](.success(comments))
        }
        
        func completeCommentsLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            completions[index](.failure(error))
        }
    }
}

private extension ImageCommentsViewController {
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedCommentsReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func numberOfRenderedImageComments() -> Int {
        return tableView.numberOfRows(inSection: 0)
    }
    
    func comment(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedImageComments() > row else {
            return nil
        }
        let datasource = tableView.dataSource
        let index = IndexPath(row: row, section: 0)
        return datasource?.tableView(tableView, cellForRowAt: index)
    }
}

private extension Date {
    
    func relativeDate(to date: Date = Date()) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: date)
    }
}

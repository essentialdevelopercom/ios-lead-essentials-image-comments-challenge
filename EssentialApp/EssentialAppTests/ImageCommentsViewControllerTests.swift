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
            self?.tableModel = (try? result.get()) ?? []
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
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
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComment() {
        let comment0 = ImageComment(id: UUID(), message: "message0", createdAt: Date(), username: "username0")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)
        
        let dataSource = sut.tableView.dataSource
        let index = IndexPath(row: 0, section: 0)
        let cell = dataSource?.tableView(sut.tableView, cellForRowAt: index) as? ImageCommentCell
        
        XCTAssertEqual(cell?.author.text, comment0.username)
        XCTAssertEqual(cell?.date.text, comment0.createdAt.relativeDate())
        XCTAssertEqual(cell?.message.text, comment0.message)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, client: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ImageCommentsViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
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
    }
}

private extension ImageCommentsViewController {
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedCommentsReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

private extension Date {
    
    func relativeDate(to date: Date = Date()) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: date)
    }
}

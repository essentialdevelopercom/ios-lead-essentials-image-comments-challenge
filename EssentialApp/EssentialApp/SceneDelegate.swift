//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import CoreData
import Combine
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	private lazy var httpClient: HTTPClient = {
		URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}()
	
	private lazy var store: FeedStore & FeedImageDataStore = {
		try! CoreDataFeedStore(
			storeURL: NSPersistentContainer
				.defaultDirectoryURL()
				.appendingPathComponent("feed-store.sqlite"))
	}()
	
	private lazy var localFeedLoader: LocalFeedLoader = {
		LocalFeedLoader(store: store, currentDate: Date.init)
	}()
	
	private lazy var localImageLoader: LocalFeedImageDataLoader = {
		LocalFeedImageDataLoader(store: store)
	}()
	
	private lazy var navigationController = UINavigationController(
			rootViewController: FeedUIComposer.feedComposedWith(
				feedLoader: makeRemoteFeedLoaderWithLocalFallback,
				imageLoader: makeLocalImageLoaderWithRemoteFallback,
				onSelect: onFeedImageSelect))
	
	convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
		self.init()
		self.httpClient = httpClient
		self.store = store
	}
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }
		
		window = UIWindow(windowScene: scene)
		configureWindow()
	}
	
	func configureWindow() {
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		localFeedLoader.validateCache { _ in }
	}
	
	private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
		let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
		return httpClient
			.getPublisher(url: url)
			.tryMap(FeedItemsMapper.map)
			.caching(to: localFeedLoader)
			.fallback(to: localFeedLoader.loadPublisher)
	}
	
	private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> AnyPublisher<Data, Error> {
		return localImageLoader
			.loadImageDataPublisher(from: url)
			.fallback(to: { [httpClient, localImageLoader] in
				httpClient
					.getPublisher(url: url)
					.tryMap(ImageDataMapper.map)
					.caching(to: localImageLoader, using: url)
			})
	}
	
	private func onFeedImageSelect(_ feedImage: FeedImage) {
		let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(feedImage.id)/comments")!
		let httpClient = httpClient
		let remoteCommentsLoader = {
			httpClient
			.getPublisher(url: url)
			.tryMap(ImageCommentsMapper.map)
			.eraseToAnyPublisher()
		}
		let commentsController = CommentsUIComposer.commentsComposedWith(commentsLoader: remoteCommentsLoader)
		navigationController.pushViewController(commentsController, animated: true)
	}
}

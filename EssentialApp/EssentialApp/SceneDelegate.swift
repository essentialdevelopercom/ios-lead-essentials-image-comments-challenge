//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import CoreData
import Combine
import EssentialFeed
import EssentialFeediOS

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
	
	private lazy var remoteFeedLoader: RemoteFeedLoader = {
		RemoteFeedLoader(
			url: URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!,
			client: httpClient)
	}()
	
	private lazy var localFeedLoader: LocalFeedLoader = {
		LocalFeedLoader(store: store, currentDate: Date.init)
	}()
	
	private lazy var remoteImageLoader: RemoteFeedImageDataLoader = {
		RemoteFeedImageDataLoader(client: httpClient)
	}()
	
	private lazy var localImageLoader: LocalFeedImageDataLoader = {
		LocalFeedImageDataLoader(store: store)
	}()

	private func remoteImageCommentsLoader(imageID id: String) -> RemoteImageCommentsLoader {
		RemoteImageCommentsLoader(url: URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(id)/comments")!,
		                          client: httpClient)
	}

	private lazy var animationsEnabled: Bool = {
		true
	}()
	
	convenience init(httpClient: HTTPClient, store: (FeedStore & FeedImageDataStore)? = nil, animationsEnabled: Bool = true) {
		self.init()
		self.httpClient = httpClient
		if let store = store {
			self.store = store
		}
		self.animationsEnabled = animationsEnabled
	}
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }
		
		window = UIWindow(windowScene: scene)
		configureWindow()
	}
	
	func configureWindow() {
		let feeedViewController = FeedUIComposer.feedComposedWith(
			feedLoader: makeRemoteFeedLoaderWithLocalFallback,
			imageLoader: makeLocalImageLoaderWithRemoteFallback
		)
		feeedViewController.navigationDelegate = self

		window?.rootViewController = UINavigationController(rootViewController: feeedViewController)
		window?.makeKeyAndVisible()
	}

	func navigateToDetails(with imageID: String, animated: Bool = true) {
		let detailsViewController = ImageCommentsUIComposer.imageCommentsComposedWith(
			imageCommentsLoader: makeRemoteImageCommentsLoader(id: imageID)
		)
		(window?.rootViewController as? UINavigationController)?.pushViewController(detailsViewController, animated: animated)
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		localFeedLoader.validateCache { _ in }
	}
	
	private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
		return remoteFeedLoader
			.loadPublisher()
			.caching(to: localFeedLoader)
			.fallback(to: localFeedLoader.loadPublisher)
	}
	
	private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
		return localImageLoader
			.loadImageDataPublisher(from: url)
			.fallback(to: { [remoteImageLoader, localImageLoader] in
				remoteImageLoader
					.loadImageDataPublisher(from: url)
					.caching(to: localImageLoader, using: url)
			})
	}

	private func makeRemoteImageCommentsLoader(id: String) -> ImageCommentsLoader.Publisher {
		remoteImageCommentsLoader(imageID: id).loadPublisher()
	}
}

extension SceneDelegate: FeedViewControllerNavigationDelegate {
	func didTapImageWith(id: String) {
		navigateToDetails(with: id, animated: animationsEnabled)
	}
}

//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import CoreData
import Combine
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	private lazy var navigationController: UINavigationController = UINavigationController(
		rootViewController: FeedUIComposer.feedComposedWith(
			   feedLoader: makeRemoteFeedLoaderWithLocalFallback,
			   imageLoader: makeLocalImageLoaderWithRemoteFallback,
			   didSelectImage: { [weak self] image in
				   self?.navigateToImageComments(feedImage: image)
			   }
			   ))
	
	private let api = EssentialFeedAPI(baseURL:  URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!)
	
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
			url: api.url(for: EssentialFeedAPI.Endpoint.feed),
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
	
	private func navigateToImageComments(feedImage: FeedImage){
		let loader = RemoteImageCommentsLoader(client: httpClient, url: api.url(for: EssentialFeedAPI.Endpoint.imageComments(id: feedImage.id)))
		let controller = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader.loadPublisher)
		navigationController.pushViewController(controller, animated: true)
	}
}

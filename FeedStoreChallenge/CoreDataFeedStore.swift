//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

@objc(CoreDataFeed)
class CoreDataFeed: NSManagedObject {
	@NSManaged public var timestamp: Date
	@NSManaged public var feedImages: NSOrderedSet
}

@objc(CoreDataFeedImage)
class CoreDataFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var feed: CoreDataFeed
}

public final class CoreDataFeedStore: FeedStore {
	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	struct ModelNotFound: Error {
		let modelName: String
	}

	public init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
		}

		container = try NSPersistentContainer.load(
			name: CoreDataFeedStore.modelName,
			model: model,
			url: storeURL
		)
		context = container.newBackgroundContext()
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		let context = context
		context.perform {
			do {
				let request = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataFeed.className())
				let result = try context.fetch(request)

				if let feed = result.first as? CoreDataFeed {
					completion(
						.found(
							feed: feed.feedImagesArray().map { $0.mapToLocalFeedImage() },
							timestamp: feed.timestamp
						)
					)
				} else {
					completion(.empty)
					return
				}
			} catch {
				completion(.failure(error))
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.context
		context.perform {
			do {
				_ = feed.createCoreDataFeed(with: timestamp, in: context)
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		fatalError("Must be implemented")
	}
}

extension CoreDataFeed {
	func feedImagesArray() -> [CoreDataFeedImage] {
		feedImages.compactMap { image in
			return image as? CoreDataFeedImage ?? nil
		}
	}
}

extension Collection where Element == LocalFeedImage {
	func createCoreDataFeed(with timestamp: Date, in context: NSManagedObjectContext) -> CoreDataFeed {
		let feed = CoreDataFeed(context: context)
		let feedImagesSet = NSOrderedSet(array: map { $0.mapToCoreData(in: context) })
		feed.timestamp = timestamp
		feed.feedImages = feedImagesSet
		return feed
	}
}

extension CoreDataFeedImage {
	func mapToLocalFeedImage() -> LocalFeedImage {
		return LocalFeedImage(
			id: id,
			description: imageDescription,
			location: location,
			url: url
		)
	}
}

extension LocalFeedImage {
	func mapToCoreData(in context: NSManagedObjectContext) -> CoreDataFeedImage {
		let feedImage = CoreDataFeedImage(context: context)
		feedImage.id = id
		feedImage.imageDescription = description
		feedImage.location = location
		feedImage.url = url.absoluteURL
		return feedImage
	}
}

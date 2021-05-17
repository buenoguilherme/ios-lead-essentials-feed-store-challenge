//
//  CoreDataFeed.swift
//  FeedStoreChallenge
//
//  Created by Guilherme Bueno on 16/05/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

@objc(CoreDataFeed)
class CoreDataFeed: NSManagedObject {
	@NSManaged public var timestamp: Date
	@NSManaged public var feedImages: NSOrderedSet
}

extension CoreDataFeed {
	static var defaultFetchRequest: NSFetchRequest<NSFetchRequestResult> {
		return NSFetchRequest(entityName: CoreDataFeed.className())
	}

	static func first(in context: NSManagedObjectContext) throws -> CoreDataFeed? {
		return try context.fetch(CoreDataFeed.defaultFetchRequest).first as? CoreDataFeed
	}

	static func deleteFirst(in context: NSManagedObjectContext) throws {
		if let feed = try CoreDataFeed.first(in: context) {
			context.delete(feed)
		}
	}

	func localFeedImages() -> [LocalFeedImage] {
		feedImages.compactMap { image in
			return (image as? CoreDataFeedImage)?.mapToLocalFeedImage()
		}
	}

	@discardableResult
	static func createCoreDataFeed(_ feed: [LocalFeedImage], with timestamp: Date, in context: NSManagedObjectContext) -> CoreDataFeed {
		let coreDataFeed = CoreDataFeed(context: context)
		coreDataFeed.timestamp = timestamp
		coreDataFeed.feedImages = NSOrderedSet(array: feed.map { $0.mapToCoreData(in: context) })
		return coreDataFeed
	}
}

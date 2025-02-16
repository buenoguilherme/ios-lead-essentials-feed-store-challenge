//
//  CoreDataFeed.swift
//  FeedStoreChallenge
//
//  Created by Guilherme Bueno on 16/05/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

@objc(CoreDataFeed)
final class CoreDataFeed: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var images: NSOrderedSet
}

extension CoreDataFeed {
	private static var defaultFetchRequest: NSFetchRequest<NSFetchRequestResult> {
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
		images.compactMap { image in
			return (image as? CoreDataFeedImage)?.mapToLocalFeedImage()
		}
	}

	@discardableResult
	static func createCoreDataFeed(_ images: [LocalFeedImage], with timestamp: Date, in context: NSManagedObjectContext) -> CoreDataFeed {
		let feed = CoreDataFeed(context: context)
		feed.timestamp = timestamp
		feed.images = NSOrderedSet(array: images.map { $0.mapToCoreData(in: context) })
		return feed
	}
}

//
//  LocalFeedImage+CoreDataMap.swift
//  FeedStoreChallenge
//
//  Created by Guilherme Bueno on 16/05/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

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

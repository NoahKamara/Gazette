//
//  Navigation.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import Foundation
import GazetteCore
import GazetteDB
import OSLog
import SwiftData
import SwiftUI

@Observable
public class Navigation {
	private static let logger = Logger(subsystem: "com.noahkamara.gazette", category: "Navigation")
	
	var content: Content? {
		willSet {
			Self.logger.debug("changing content")
			withMutation(keyPath: \.article) {
				self.article = nil
			}
		}
	}

	var article: PersistentIdentifier?
	var sheet: SheetID?
	
	func handleURL(_ url: URL) {
		switch url.scheme {
		case "feed":
			self.show(.addFeed(url))
		default:
			print("Unknown URL", url)
		}
	}

	enum SheetID: Equatable {
		case addFeed(_ feedURL: URL?)
		case editFeed(Feed)
		case previewFeed(TransientFeed)
	}
	
	func show(_ newSheet: SheetID) {
		Self.logger.debug("show '\(String(describing: newSheet))'")
		
		withMutation(keyPath: \.sheet) {
			self.sheet = newSheet
		}
	}

	func goto(_ feed: Feed) {
		Self.logger.info("navigating to feed \(feed.persistentModelID.entityName)")
		
		withMutation(keyPath: \.content) {
			withMutation(keyPath: \.article) {
				self.article = nil
				self.content = .feed(feed)
			}
		}
	}
	
	func pop() {
		guard self.article == nil else {
			Self.logger.debug("popping to content")
			withMutation(keyPath: \.article) {
				self.article = nil
			}
			return
		}
		
		guard self.content == nil else {
			Self.logger.debug("popping to root")
			withMutation(keyPath: \.content) {
				self.content = nil
			}
			return
		}
		
		Self.logger.debug("nothing to pop")
	}
	
	enum Content: Hashable {
		case all
		case today
		case feed(Feed)
	}
}

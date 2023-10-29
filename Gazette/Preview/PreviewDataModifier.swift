//
//  PreviewDataModifier.swift
//
//
//  Created by Noah Kamara on 16.10.23.
//

import GazetteDB
import SwiftData
import SwiftUI

struct PreviewDataModifier: ViewModifier {
	@Environment(\.modelContext)
	private var context
	
	let onSetup: (Persistence) async -> Void
	
	func body(content: Content) -> some View {
		content
			.task(id: "preview-data", priority: .userInitiated) {
				let persistence = Persistence(modelContainer: context.container)
				await self.onSetup(persistence)
				try? await persistence.save()
			}
	}
}

public enum PreviewFeeds: String, CaseIterable {
	case appleNews = "http://images.apple.com/main/rss/hotnews/hotnews.rss"
	case spon = "https://www.spiegel.de/schlagzeilen/tops/index.rss"
	case welt = "https://www.welt.de/feeds/section/politik.rss"
	case guardian = "https://www.theguardian.com/world/rss"
	case macrum = "https://forums.macrumors.com/forums/-/index.rss"
	
	var url: URL {
		URL(string: rawValue)!
	}
}

public extension Set where Element == PreviewFeeds {
	static let all = Self(PreviewFeeds.allCases)
}

import GazetteParsing

public extension View {
	@ViewBuilder
	func preview(
		createContainer: Bool = true,
		onSetup: @escaping (Persistence) async -> Void
	) -> some View {
		if createContainer {
			self
				.modifier(PreviewDataModifier(onSetup: onSetup))
				.persistence(inMemory: true)
		} else {
			self
				.modifier(PreviewDataModifier(onSetup: onSetup))
				.persistence(inMemory: true)
		}
	}
	
	func preview(
		createContainer: Bool = true,
		rss feeds: Set<PreviewFeeds> = .all
	) -> some View {
		self
			.preview(createContainer: createContainer) { persistence in
				for feed in feeds {
					do {
						let feed = try await FeedParser().parse(url: feed.url)
						await persistence.insert(feed)
					} catch {
						print(error)
					}
				}
			}
	}
}

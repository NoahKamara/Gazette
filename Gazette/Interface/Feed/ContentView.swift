//
//  ContentView.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import GazetteDB
import SwiftData
import SwiftUI

struct ContentView: View {
	@Environment(Navigation.self)
	private var navigation
	
	@Environment(\.modelContext)
	var context
	
	private var today: Date { Calendar.current.startOfDay(for: .now) }
	var body: some View {
		Group {
			switch self.navigation.content {
			case .all:
				StaticListContentView("All", filter: .all)
			case .today:
				StaticListContentView("Today", filter: #Predicate<Article> {
					if let pubDate = $0.pubDate {
						(pubDate.timeIntervalSinceReferenceDate - self.today.timeIntervalSinceReferenceDate) < 60*60*24
					} else { true }
				})
			case .none:
				Text("None Selected")
			case .feed(let feed):
				FeedContentView(feed: feed)
			}
		}
		.toolbarTitleDisplayMode(.inline)
		// #if !os(macOS)
//		.navigationBarTitleDisplayMode(.inline)
//
		// #endif
	}
}

extension Predicate {
	static var all: Predicate<Article> { #Predicate<Article> { _ in true } }
}

// #Preview("Content Column") {
//	@State
//	var article = PersistentIdentifier?.none
//
//	return NavigationSplitView {
//		EmptyView()
//	} content: {
//		ContentView().preview()
//	} detail: {
//		EmptyView()
//	}
// }

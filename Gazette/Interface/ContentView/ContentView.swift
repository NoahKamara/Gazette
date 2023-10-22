//
//  ContentView.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import SwiftUI
import GazetteDB
import SwiftData

struct ContentView: View {
	@Environment(Navigation.self)
	private var navigation
	
	@Environment(\.modelContext)
	var context
	
    var body: some View {
		Group {
			switch navigation.content {
			case .all:
				StaticListContentView("All", filter: .all)
			case .none:
				Text("None Selected")
			case .feed(let feed):
				FeedContentView(feed: feed)
			}
		}
    }
}

extension Predicate {
	static var all: Predicate<Article> { #Predicate<Article> { _ in true } }
}

//#Preview("Content Column") {
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
//}

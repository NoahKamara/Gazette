//
//  MainView.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import SwiftUI
import GazetteDB
import SwiftData
import OSLog

@Observable
public class Navigation {
	private static let logger = Logger(subsystem: "com.noahkamara.gazette", category: "Navigation")
	
	var content: Content? = nil {
		willSet {
			withMutation(keyPath: \.article) {
				article = nil
			}
		}
	}
	
	var article: PersistentIdentifier? = nil
	
	func goto(_ feed: Feed) {
		Self.logger.info("navigating to feed \(feed.persistentModelID.entityName)")
		
		withMutation(keyPath: \.content) {
			withMutation(keyPath: \.article) {
				article = nil
				content = .feed(feed)
			}
		}
	}
	
	func pop() {
		guard article == nil else {
			debugPrint("popping to content")
			withMutation(keyPath: \.article) {
				article = nil
			}
			return
		}
		
		guard content == nil else {
			debugPrint("popping to root")
			withMutation(keyPath: \.content) {
				content = nil
			}
			return
		}
	}
	
	enum Content: Hashable {
		case all
		case feed(Feed)
	}
}


struct MainView: View {
	@Bindable
	var navigation = Navigation()
	
	@Environment(\.horizontalSizeClass)
	private var horizontalSizeClass
	
	@Environment(\.modelContext)
	private var context
	
	@State
	private var columnVisibility: NavigationSplitViewVisibility = .all

	var body: some View {
		NavigationSplitView(columnVisibility: $columnVisibility) {
			SidebarView(selection: $navigation.content)
		} content: {
			ContentView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.environment(navigation)
				.background(.background.secondary)
				.navigationDestination(for: Article.self) { article in
					ArticleDetailView(article: article)
						.background(.background.secondary)
						.onChange(of: article, initial: true) { _, newValue in
							self.navigation.article = newValue.id
						}
//						.onDisappear(perform: {
//							self.navigation.article = nil
//						})
				}
		} detail: {
			Text("No Detail")
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(.background.secondary)
		}
		.navigationSplitViewStyle(.balanced)
		.environment(navigation)
	}
}

#Preview {
	MainView()
		.preview(rss: .all)
}

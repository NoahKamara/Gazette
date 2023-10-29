//
//  MainView.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import GazetteCore
import GazetteDB
import OSLog
import SwiftData
import SwiftUI
import SwiftUINavigation

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
		NavigationSplitView(columnVisibility: self.$columnVisibility) {
			SidebarView(selection: self.$navigation.content)
		} content: {
			ContentView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.environment(self.navigation)
				.background(.background.secondary)
				.navigationDestination(for: Article.self) { article in
					ArticleDetailView(article: article)
						.background(.background.secondary)
						.onChange(of: article, initial: true) { _, newValue in
							self.navigation.article = newValue.id
						}
				}
		} detail: {
			Text("No Detail")
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(.background.secondary)
		}
		.navigationSplitViewStyle(.balanced)

		// MARK: Screens

		.addFeedScreen()
		.editFeedScreen()
		.previewFeedScreen()
		.environment(self.navigation)
		.onOpenURL(perform: self.navigation.handleURL)
	}
}

#Preview {
	MainView()
		.preview(rss: .all)
}

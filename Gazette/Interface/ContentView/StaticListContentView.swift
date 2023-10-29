//
//  StaticListContentView.swift
//  Gazette
//
//  Created by Noah Kamara on 19.10.23.
//

import GazetteDB
import SwiftUI

struct StaticListContentView: View {
	init(
		_ titleKey: LocalizedStringKey,
		filter: Predicate<Article>
	) {
		self.title = Text(titleKey)
		self.query = Articles()
		self.query.content = .all
	}
	
	let title: Text
	
	@State
	var query: Articles
	
	@Environment(Navigation.self)
	var nav
	
	@Environment(\.modelContext)
	private var context
	
	@State
	private var showTitle: Bool = false
	
	var body: some View {
		@Bindable var nav = nav
		ArticleCollectionView2(selection: $nav.article) {
			self.title
				.font(.largeTitle)
				.fontWeight(.bold)
				.fontDesign(.serif)
				.lineLimit(2)
				.multilineTextAlignment(.center)
				.padding(20)
				.frame(height: 120)
				.isScrollHidden(self.$showTitle)
		}
		.environment(\.articleProps.showsFeed, true)
		.refreshable {
			print("REFRESH FEED")
			try? await Task.sleep(for: .seconds(2))
		}
		.navigationTitle(self.showTitle ? self.title : Text(""))
		.toolbarTitleDisplayMode(.inline)
#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
#endif
	}
}

#Preview {
	StaticListContentView("All", filter: .all)
}

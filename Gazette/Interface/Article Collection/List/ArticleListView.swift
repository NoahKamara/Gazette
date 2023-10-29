//
//  ArticleListView.swift
//  Gazette
//
//  Created by Noah Kamara on 17.10.23.
//

import GazetteDB
import SwiftData
import SwiftUI

struct ArticleListView: View {
	var query: Articles
	
	@Binding
	var selection: PersistentIdentifier?
	
	var body: some View {
		List {
			ForEach(self.query.articles) { article in
				NavigationLink(value: article) {
					Row(article: article)
				}
				.buttonStyle(.plain)
				.safeAreaPadding(.horizontal, 15)
				.padding(.vertical, 5)
				.background {
					if self.selection == article.id {
						ContainerRelativeShape()
							.fill(Color.accentColor.quaternary)
					} else {
						EmptyView()
					}
				}
			}
		}
		.safeAreaPadding(.bottom, 20)
	}
}

//
#Preview {
	ModelPreview(rss: .spon) { feed in
		NavigationStack {
			FeedContentView(feed: feed)
				.environment(Navigation())
		}
	}
}

// MARK: Row

extension ArticleListView {
	struct Row: View {
		@Environment(\.articleProps)
		private var config
		
		@Bindable
		var article: Article
		
		var body: some View {
			HStack(alignment: .top, spacing: 10) {
				if self.config.showsFeed {
					if let feed = article.feed {
						FeedIcon(feed: feed)
					} else {
						ContainerRelativeShape()
							.aspectRatio(1, contentMode: .fit)
							.frame(width: 25, height: 25)
							.foregroundStyle(.secondary)
					}
				}
				
				HStack(alignment: .top) {
					VStack(alignment: .leading) {
						Text(self.article.title ?? "Untitled Article")
							.fontWeight(.semibold)
							.lineLimit(3)
						
						if let descr = article.descr {
							Text(descr)
								.font(.callout)
								.foregroundStyle(.secondary)
								.lineLimit(1)
						}
					}
					.frame(maxWidth: .infinity, alignment: .topLeading)
					
					if let image = article.image {
						AssetViewNew(asset: image) {
							$0
								.resizable()
								.scaledToFill()
						}
						.aspectRatio(1, contentMode: .fit)
						.frame(width: 90)
						.clipShape(ContainerRelativeShape())
					}
				}
				.safeAreaInset(edge: .top, spacing: 3, content: {
					HStack(alignment: .top) {
						if self.config.showsFeed, let feed = article.feed {
							Text(feed.title ?? "Untitled Feed")
								.frame(maxWidth: .infinity, alignment: .leading)
						} else { Spacer() }
						
						if let date = article.pubDate {
							if Date.now.timeIntervalSince(date) < 60*60 {
								Text(date, format: .relative(presentation: .named, unitsStyle: .abbreviated))
							} else {
								Text(date, format: Date.FormatStyle(time: .shortened))
							}
						}
					}
					.foregroundStyle(.secondary)
					.fontWeight(.semibold)
					.font(.caption.smallCaps())
				})
			}
			.containerShape(RoundedRectangle(cornerRadius: 5))
			.swipeActions(edge: .trailing, allowsFullSwipe: true) {
				Button(action: { self.article.isRead.toggle() }, label: {
					Image(systemName: "circle")
						.symbolVariant(self.article.isRead ? .slash : .none)
				})
			}
			.contextMenu {
				ToggleReadArticleButton(self.article)
				BookmarkArticleButton(self.article)
				ShareArticleButton(self.article)
			}
			.foregroundStyle(!self.article.isRead ? HierarchicalShapeStyle.primary : .secondary)
		}
	}
}

// #Preview("Article List") {
//	@State var sorting = ArticleSorting()
//	@State var selection = PersistentIdentifier?.none
//
//	return ModelPreview(rss: .spon) { feed in
//		ArticleCollectionView(
//			feed: feed,
//			sorting: $sorting,
//			selection: $selection
//		)
//	}
// }
//

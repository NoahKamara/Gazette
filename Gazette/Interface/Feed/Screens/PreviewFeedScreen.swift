//
//  PreviewFeedScreen.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import GazetteCore
import SwiftUI

private struct PreviewFeedScreen: View {
	let feed: TransientFeed
	
	var body: some View {
		ScrollView {
			ForEach(self.feed.articles) { article in
				ArticleRow(article: article)
			}
		}
		.safeAreaInset(edge: .top, content: {
			FormView {
				Label {
					Text(self.feed.title ?? "Untitled Feed")
				} icon: {
					FeedIcon(asset: self.feed.icon)
						.clipShape(RoundedRectangle(cornerRadius: 10))
						.frame(height: 35)
				}
				.minimumScaleFactor(0.5)
				.lineLimit(1)
			}
		})
		.safeAreaInset(edge: .bottom, content: {
			FormButton("Add Feed", action: {})
		})
		.containerShape(RoundedRectangle(cornerRadius: 25))
	}
}

import SwiftUINavigation

extension View {
	func previewFeedScreen() -> some View {
		self.sheet(for: /Navigation.SheetID.previewFeed) { $feed in
			PreviewFeedScreen(feed: feed)
				.customSheet()
		}
	}
}

private struct ArticleRow: View {
	@Environment(\.articleProps)
	private var config
	
	let article: TransientArticle
	
	var body: some View {
		HStack(alignment: .top, spacing: 10) {
			HStack(alignment: .top) {
				VStack(alignment: .leading) {
					Text(self.article.title ?? "Untitled Article")
						.fontWeight(.semibold)
						.lineLimit(3)
					
					if let descr = article.description {
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
	}
}

//
//  ArticleDetailView.swift
//  Gazette
//
//  Created by Noah Kamara on 17.10.23.
//

import SwiftUI
import GazetteDB

struct ArticleDetailView: View {
	@Environment(Navigation.self)
	private var navigation
	
	@Environment(\.dismiss)
	private var dismiss
	
	let article: Article
	
	@State
	private var showNavTitle: Bool = false
	
    var body: some View {
		ScrollView {
			LazyVStack(alignment: .leading, spacing: 30) {
				// MARK: Header
				VStack(alignment: .leading, spacing: 10) {
					HStack(alignment: .top) {
						if let feed = article.feed {
							Menu {
								Button(action: { navigation.goto(feed); dismiss() }, label: {
									Label("View Feed", systemImage: "rectangle.grid.1x2")
								})
								
								Button(action: {}, label: {
									Label("Edit Feed", systemImage: "pencil")
								})
							} label: {
								Text(feed.title ?? "Untitled Feed")
									.frame(maxWidth: .infinity, alignment: .leading)
									.multilineTextAlignment(.leading)
							}
							.foregroundStyle(Color.accentColor)
						}
						
						if let date = article.pubDate {
							if Date.now.timeIntervalSince(date) < 60*60 {
								Text(date, format: .relative(presentation: .named, unitsStyle: .abbreviated))
							} else {
								Text(date, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
							}
						}
					}
					.foregroundStyle(.secondary)
					.fontWeight(.semibold)
					.font(.callout.smallCaps())
					.containerShape(RoundedRectangle(cornerRadius: 8))
					
					Text(article.title ?? "Untitled Article")
						.font(.largeTitle)
						.fontWeight(.heavy)
						.fontDesign(.serif)
						.lineLimit(3)
						.minimumScaleFactor(0.5)
					
					ScrollViewOffsetTracker()
						.onScroll { point in
							let newValue = point.y < 10
							withAnimation(.interactiveSpring) {
								self.showNavTitle = newValue
							}
							
						}
					Divider()
				}
				.lineSpacing(0)
				if let descr = article.descr {
					ForEach(0..<13) { _ in
						Text(descr)
					}
					
				}
			}
				.lineSpacing(10)
				.safeAreaPadding(15)
				.frame(maxWidth: 700)
				.frame(maxWidth: .infinity)
		}
		.navigationTitle(showNavTitle ? article.title ?? "" : "")
		.toolbarTitleDisplayMode(.inline)
		.toolbar {
#if !os(macOS)
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					Button(action: {}) {
						Label("App Link", systemImage: "appclip")
					}
					
					ShareLink(item: article.url) {
						Label("Article Link", systemImage: "link")
					}
					
					Button(action: {}) {
						Label("Markdown", systemImage: "doc.richtext")
					}
				} label: {
					Image(systemName: "square.and.arrow.up")
				}
				
			}
			
			ToolbarItem(placement: .topBarTrailing) {
				Button(action: {}, label: {
					Image(systemName: "textformat")
				})
			}
			
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					Button(action: {}) {
						Text("HELLO")
					}
				} label: {
					Image(systemName: "ellipsis")
				}
				
			}
#endif
		}
		.onAppear {
			article.isRead = true
		}
		
    }
}

#Preview {
	ModelPreview(rss: .spon) { article in
		NavigationStack {
			ArticleDetailView(article: article)
				.background(.background.secondary)
				.environment(Navigation())
		}
	}
}

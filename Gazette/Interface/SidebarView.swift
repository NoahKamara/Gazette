//
//  SidebarView.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import SwiftUI


struct SidebarView: View {
	@Binding
	var selection: Navigation.Content?
	
	@Query var feeds: [Feed]
	
	@State
	private var newFeedSheet: Bool = false
	
	var body: some View {
		List(selection: $selection) {
			Section("Pinned") {
				Text("Hello")
			}
			
			Section {
				Label("All", systemImage: "rectangle.grid.2x2")
					.tag(Navigation.Content.all)
				
				Label("Today", systemImage: "calendar")
				
				Label("This Week", systemImage: "calendar")
			}
			
			Section("Collections") {
				Text("Hello")
			}
			
			Section("Feeds") {
				ForEach(feeds) { feed in
					Label {
						LabeledContent {
							Text("0")
						} label: {
							Text(feed.title ?? "Untitled Feed")
								.lineLimit(1)
						}

					} icon: {
						FeedIcon(feed: feed)
					}
					.tag(Navigation.Content.feed(feed))
					.containerShape(RoundedRectangle(cornerRadius: 5))
				}
			}
		}
		.listStyle(.sidebar)
		.navigationTitle("Gazette")
#if !os(macOS)
		.toolbar(content: {
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					Button(action: { newFeedSheet = true }) {
						Label("Subscribe Feed", systemImage: "badge.plus.radiowaves.right")
					}
					
					Button(action: {}, label: {
						Label("Add List", systemImage: "rectangle.stack.badge.plus")
					})
					
					Button(action: {}, label: {
						Label("Add Filter", systemImage: "gearshape.2")
					})
					
					Divider()
					
					Button(action: {}, label: {
						Label("What's New", systemImage: "questionmark")
					})
					
					Button(action: {}, label: {
						Label("Preferences", systemImage: "gear")
					})
				} label: {
					Image(systemName: "ellipsis")
						.imageScale(.large)
				}
				
			}

		})
#endif
		.sheet(isPresented: $newFeedSheet, content: {
			AddFeedSheet(feedURL: URL(string: "https://www.spiegel.de/schlagzeilen/tops/index.rss"))
		})
	}
}

#Preview {
	@State var content = Navigation.Content?.none
	return SidebarView(selection: $content)
		.preview(rss: .all)
}

import GazetteDB
import SwiftData

struct FeedSection: View {
	@Query var feeds: [Feed]
	
	var body: some View {
		Section("Feeds") {
			ForEach(feeds) { feed in
				Label {
					Text("Spiegel: Top News")
				} icon: {
					ContainerRelativeShape()
						.aspectRatio(1, contentMode: .fit)
				}
				.tag(feed)
			}
		}
	}
}

#Preview {
	List {
		FeedSection()
	}
	.listStyle(.sidebar)
	.preview()
}

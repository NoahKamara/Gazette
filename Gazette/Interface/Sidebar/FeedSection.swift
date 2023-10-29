//
//  FeedSection.swift
//  Gazette
//
//  Created by Noah Kamara on 28.10.23.
//

import GazetteDB
import SwiftData
import SwiftUI

extension SidebarView {
	struct FeedSection: View {
		@Query var feeds: [Feed]
		
		var body: some View {
			Section("Feeds") {
				ForEach(self.feeds) { feed in
					FeedItem(feed: feed)
				}
			}
		}
	}
	
	fileprivate struct FeedItem: View {
		let feed: Feed
		
		var body: some View {
			Label {
				LabeledContent {
					Text("0")
				} label: {
					Text(self.feed.title ?? "Untitled Feed")
						.lineLimit(1)
				}
				
			} icon: {
				FeedIcon(feed: self.feed)
			}
			.tag(Navigation.Content.feed(self.feed))
			.containerShape(RoundedRectangle(cornerRadius: 5))
			.contextMenu {
				EditFeedButton(self.feed)
				ShareFeedButton(self.feed)
				Divider()
				DeleteFeedButton(self.feed)
			}
		}
	}
}

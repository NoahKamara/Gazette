//
//  FeedEditScreen.swift
//  Gazette
//
//  Created by Noah Kamara on 18.10.23.
//

import SwiftUI

import GazetteCore
import GazetteDB
import GazetteParsing

private struct FeedEditView: View {
	@Bindable
	var feed: Feed
	
	@Environment(\.dismiss)
	private var dismiss
	
	@Environment(\.modelContext)
	private var context
	
	func save() {
		do {
			try self.context.save()
		} catch {
			print(error)
		}
	}
	
	var body: some View {
		FormView {
			if let banner = feed.image {
				AssetView(asset: banner)
					.frame(maxWidth: .infinity)
					.padding(20)
			}
			
			Label {
				TextField("Untitled Feed", text: self.$feed.title ?? "")
			} icon: {
				FeedIcon(feed: self.feed)
					.containerShape(RoundedRectangle(cornerRadius: 5))
			}
			
			FormButton("Save", action: { self.save(); self.dismiss() })
		}
		.frame(minHeight: 120)
	}
}

import SwiftUINavigation

extension View {
	func editFeedScreen() -> some View {
		self.sheet(for: /Navigation.SheetID.editFeed) { $feed in
			FeedEditView(feed: feed)
				.customSheet()
		}
	}
}

#Preview("Feed Edit") {
	ModelPreview(rss: .spon) {
		FeedEditView(feed: $0)
	}
}

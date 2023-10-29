//
//  DeleteFeedButton.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import GazetteDB
import SwiftUI

struct DeleteFeedButton: View {
	let feed: Feed
	
	init(_ feed: Feed) {
		self.feed = feed
	}
	
	@Environment(\.modelContext)
	private var context
	
	var body: some View {
		Menu {
			Button(role: .destructive, action: { self.context.delete(self.feed) }) {
				Label("Delete feed", systemImage: "trash")
			}
			
			Button(action: {}) {
				Text("Cancel")
			}
		} label: {
			Label("Delete feed", systemImage: "trash")
		}
	}
}

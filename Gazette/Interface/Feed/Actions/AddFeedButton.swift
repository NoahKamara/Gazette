//
//  AddFeedButton.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import GazetteDB
import SwiftUI

struct AddFeedButton: View {
	@Environment(Navigation.self)
	private var navigation
	
	let feedURL: URL?
	
	init(_ feedURL: URL? = nil) {
		self.feedURL = feedURL
	}
	
	var body: some View {
		Button(action: { self.navigation.show(.addFeed(self.feedURL)) }) {
			Label("Subscribe Feed", systemImage: "badge.plus.radiowaves.right")
		}
	}
}

//
//  ViewFeedButton.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import GazetteDB
import SwiftUI

struct ViewFeedButton: View {
	@Environment(Navigation.self)
	private var navigation
	
	let feed: Feed
	
	init(_ feed: Feed) {
		self.feed = feed
	}
	
	var body: some View {
		Button(action: { self.navigation.goto(self.feed) }, label: {
			Label("View Feed", systemImage: "rectangle.grid.1x2")
		})
	}
}

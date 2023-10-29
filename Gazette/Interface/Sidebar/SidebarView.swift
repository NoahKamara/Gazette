//
//  SidebarView.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import SwiftUI

struct SidebarView: View {
	@Environment(Navigation.self)
	private var navigation
	
	@Binding
	var selection: Navigation.Content?
	
	@Query
	var feeds: [Feed]
		
	var body: some View {
		List(selection: self.$selection) {
			PinnedSection(selection: self.$selection)
			
//			Section("Collections") {
//				Label("All", systemImage: "rectangle.grid.2x2")
//					.tag(Navigation.Content.all)
//
//				Label("Today", systemImage: "calendar")
//					.tag(Navigation.Content.today)
//			}
			
			FeedSection()
		}
		.listStyle(.sidebar)
		.navigationTitle("Gazette")
#if !os(macOS)
			.toolbar(content: {
				ToolbarItem(placement: .topBarTrailing) {
					Menu {
						AddFeedButton()
					
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
	}
}

#Preview {
	@State var content = Navigation.Content?.none
	return SidebarView(selection: $content)
		.preview(rss: .all)
}

import GazetteDB
import SwiftData

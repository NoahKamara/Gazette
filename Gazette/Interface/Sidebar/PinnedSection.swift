//
//  PinnedSection.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import SwiftUI

private struct PinnedItem: View {
	let isSelected: Bool
	let title: String
	let icon: String
	let tint: Color
	
	var body: some View {
		ZStack(alignment: .topLeading) {
			if self.isSelected {
				RoundedRectangle(cornerRadius: 10)
					.fill(self.tint.secondary)
			} else {
				RoundedRectangle(cornerRadius: 10)
					.fill(.background)
			}
			
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					Image(systemName: self.icon)
						.imageScale(.large)
						.fontWeight(.semibold)
						.foregroundStyle(self.isSelected ? Color.primary : self.tint)
					
					Spacer()
//					Text(Int.random(in: 0..<99), format: .number)
//						.fontWeight(.bold)
				}
				Spacer()
				Text(self.title)
					.fontWeight(.semibold)
			}
			.padding(10)
		}
	}
}

extension SidebarView {
	struct PinnedSection: View {
		@Binding
		var selection: Navigation.Content?
		
		let selections: [Navigation.Content] = [
			.all,
			.today
		]
		var body: some View {
			Section {
				LazyVGrid(columns: [.init(), .init()],
				          content: {
				          	PinnedItem(
				          		isSelected: self.selection == .all,
				          		title: "All",
				          		icon: "rectangle.grid.2x2",
				          		tint: .gray
				          	)
				          	.onTapGesture {
				          		self.selection = .all
				          	}
					
				          	PinnedItem(
				          		isSelected: self.selection == .today,
				          		title: "Today",
				          		icon: "calendar",
				          		tint: .orange
				          	)
				          	.onTapGesture {
				          		self.selection = .today
				          	}
				          })
			}
			.listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
			.listRowBackground(EmptyView())
		}
	}
}

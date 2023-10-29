//
//  FormView.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import SwiftUI

struct FormView<Content: View>: View {
	let content: Content
	
	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}
	
	@Environment(\.defaultMinListRowHeight)
	var defaultMinListRowHeight
	
	var body: some View {
		VStack(spacing: 5) {
			Group {
				self.content
			}
			.safeAreaPadding(.horizontal, 10)
			.frame(maxWidth: .infinity, minHeight: self.defaultMinListRowHeight)
			.background(in: ContainerRelativeShape())
			.backgroundStyle(.background.quaternary)
			.padding(.horizontal, 10)
		}
		.safeAreaPadding(.vertical, 10)
	}
}

#Preview {
	FormView {
		Text("Hello World")
		Text("Hello World")
		Text("Hello World")
	}
}

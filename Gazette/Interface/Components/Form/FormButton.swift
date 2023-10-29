//
//  FormButton.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import SwiftUI

struct FormButton<Content: View>: View {
	let action: () async -> Void
	let content: Content
	
	init(isLoading: Bool = false, action: @escaping () async -> Void, @ViewBuilder content: () -> Content) {
		self.action = action
		self.content = content()
		self.isLoading = isLoading
	}
	
	init(
		_ titleKey: LocalizedStringKey,
		isLoading: Bool = false,
		action: @escaping () async -> Void
	) where Content == Text {
		self.init(isLoading: isLoading, action: action, content: { Text(titleKey) })
	}
	
	@State
	var isLoading: Bool = false
	
	@State
	var task: Task<Void, Never>? = nil
	
	func performAction() {
		self.task = Task(priority: .userInitiated) {
			self.isLoading = true
			await self.action()
			self.isLoading = false
		}
	}
	
	@Environment(\.defaultMinListRowHeight)
	var defaultMinListRowHeight
	
	var body: some View {
		Button(action: self.performAction) {
			Group {
				if self.isLoading {
					ProgressView()
				} else {
					self.content
				}
			}
			.font(.headline)
			.fontDesign(.rounded)
			.padding(10)
			.frame(maxWidth: .infinity)
			.foregroundStyle(Color.primary)
			.ignoresSafeArea(.container)
		}
		.frame(minHeight: self.defaultMinListRowHeight)
		.backgroundStyle(Color.accentColor.tertiary)
	}
}

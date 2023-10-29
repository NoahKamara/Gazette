//
//  CustomSheet.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import SwiftUI

private struct AutoSizeSheet: ViewModifier {
	@State private var sheetHeight: CGFloat = .zero
	
	func body(content: Content) -> some View {
		content
			.background {
				GeometryReader { geometry in
					Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
				}
			}
			.onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
				self.sheetHeight = newHeight
			}
			.presentationDetents([.height(self.sheetHeight)])
			.animation(.interactiveSpring, value: self.sheetHeight)
	}
}

private struct InnerHeightPreferenceKey: PreferenceKey {
	static var defaultValue: CGFloat = 300
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
	}
}

private struct CustomSheetModifier: ViewModifier {
	@Environment(\.dismiss)
	private var dismiss
	
	func body(content: Content) -> some View {
		content
			.background(.background, in: ContainerRelativeShape())
			.containerShape(RoundedRectangle(cornerRadius: 25))
			.safeAreaPadding(10)
			.frame(maxHeight: .infinity, alignment: .bottom)
			.modifier(AutoSizeSheet())
			.presentationBackground {
				Color.clear
					.contentShape(Rectangle())
					.onTapGesture {
						print("DISMISS")
						self.dismiss()
					}
			}
	}
}

extension View {
	func customSheet() -> some View {
		self
			.modifier(CustomSheetModifier())
	}
}

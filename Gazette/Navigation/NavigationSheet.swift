//
//  NavigationSheet.swift
//  Gazette
//
//  Created by Noah Kamara on 29.10.23.
//

import SwiftUI
import SwiftUINavigation

private struct NavigationSheet<Case, Sheet: View>: ViewModifier {
	@Environment(Navigation.self)
	private var nav
	
	let casePath: CasePath<Navigation.SheetID, Case>
	let sheetContent: (Binding<Case>) -> Sheet
	
	init(casePath: CasePath<Navigation.SheetID, Case>, sheetContent: @escaping (Binding<Case>) -> Sheet) {
		self.casePath = casePath
		self.sheetContent = sheetContent
	}
	
	func body(content: Content) -> some View {
		@Bindable var nav = nav
		
		content
			.sheet(
				unwrapping: $nav.sheet,
				case: self.casePath,
				content: self.sheetContent
			)
	}
}

extension View {
	func sheet<Case, Sheet: View>(
		for casePath: CasePath<Navigation.SheetID, Case>,
		content: @escaping (Binding<Case>) -> Sheet
	) -> some View {
		self
			.modifier(NavigationSheet(casePath: casePath, sheetContent: content))
	}
}

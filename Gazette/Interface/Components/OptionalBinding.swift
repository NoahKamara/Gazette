//
//  OptionalBinding.swift
//  Gazette
//
//  Created by Noah Kamara on 29.10.23.
//

import SwiftUI

func ?? <T>(lhs: Binding<T?>, rhs: T) -> Binding<T> {
	Binding {
		lhs.wrappedValue ?? rhs
	} set: { newValue in
		lhs.wrappedValue = newValue
	}
}

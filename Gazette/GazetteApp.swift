//
//  GazetteApp.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import SwiftUI

@main
struct GazetteApp: App {
	
    @State
	var show = false
	
	var body: some Scene {
        WindowGroup {
			ArticleView()
//				.preview()
//				.persistence(inMemory: false)
        }
    }
}

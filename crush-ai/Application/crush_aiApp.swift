//
//  crush_aiApp.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/1/25.
//

import SwiftUI
import SwiftData

@main
struct crush_aiApp: App {
    
    let container: ModelContainer = {
        let schema = Schema([ImageEntity.self, ReplyEntity.self, DialogEntity.self, DialogGroupEntity.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}

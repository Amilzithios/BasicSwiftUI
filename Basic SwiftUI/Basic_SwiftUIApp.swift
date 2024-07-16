//
//  Basic_SwiftUIApp.swift
//  Basic SwiftUI
//
//  Created by Amilzith on 17/07/24.
//

import SwiftUI
import CoreData

@main
struct Basic_SwiftUIApp: App {
    let managedObjectConext = PersistenContainer.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, managedObjectConext.container.viewContext)
        }
    }
}


struct PersistenContainer {
    
    static let shared = PersistenContainer()
    
    var container: NSPersistentContainer
    
    init() {
        self.container = NSPersistentContainer(name: "UserData")
        self.container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Error1 \(error)")
            }
        }
    }
}

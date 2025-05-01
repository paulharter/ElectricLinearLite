//
//  LinearLiteApp.swift
//  LinearLite
//
//  Created by Paul Harter on 29/04/2025.
//

import SwiftUI
import SwiftData
import ElectricSync

@main
struct LinearLiteApp: App {
    
    var shapeManager: EphemeralShapeManager?
    var issuesPublisher: EphemeralShapePublisher<Issue>?
    
    init() {
        
        
        if let path = Bundle.main.path(forResource: "ElectricConfig", ofType: "plist") {
            
            var electricConfig: NSDictionary?
            electricConfig = NSDictionary(contentsOfFile: path)
            
            if electricConfig!["source_id"] as? String == "xxxxxx"{
                print("This demo app is not configured correctly. Please check your ElectricConfig.plist file.")
                print("You may need to add the correct source_id and source_secret from your Electric account to this app.")
            }
            
            self.shapeManager = EphemeralShapeManager(dbUrl: electricConfig!["db_url"] as! String,
                                                      sourceId: electricConfig!["source_id"] as? String,
                                                      sourceSecret: electricConfig!["source_secret"] as? String)
            
            self.issuesPublisher = self.shapeManager!.publisher(table: "issue", sort: { one, two in
                return one.created ?? Date() > two.created ?? Date()
            })
        } else {
            print("The ElectricConfig.plist file was not found in the bundle")
        }

    }
 
    var body: some Scene {

        WindowGroup {
            if let publisher = self.issuesPublisher{
                ContentView(issuesPublisher: publisher)
            }
        }.environmentObject(self.shapeManager!)
    }
}

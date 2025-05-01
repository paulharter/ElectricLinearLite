//
//  ContentView.swift
//  LinearLite
//
//  Created by Paul Harter on 29/04/2025.
//

import SwiftUI
import SwiftData
import ElectricSync

struct ContentView: View {
    @StateObject var issuesPublisher: EphemeralShapePublisher<Issue>
    
    var body: some View {
        IssueList(issuesPublisher: issuesPublisher)
    }

}


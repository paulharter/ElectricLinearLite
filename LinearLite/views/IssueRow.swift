//
//  IssueRowView.swift
//  ElectricApp
//
//  Created by Paul Harter on 03/04/2025.
//

import SwiftUI
//import UIKit

struct IssueRow: View {
    var issue: Issue


    var body: some View {
        HStack{
            Image(issue.priortyIcon())
  
                .frame(width: 20, alignment: .center)
            Image(issue.statusIcon())
  
                .frame(width: 20, alignment: .center)
            Text(issue.title).font(.subheadline)
            Spacer()
            Text(formatDate(issue.created!)).font(.caption2)
        }
    }
}

func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMM"
    return dateFormatter.string(from: date)
}


#Preview {
    
    let issue = Issue(
        id: "a9bd4dcb-178b-405e-aae9-076b4ece784d", title: "A test issue", desc: "A big issue", priority: .urgent, created: Date(), modified: Date(), kanbanorder: "c4DQ", username: "Paul", status: .backlog)
    

    IssueRow(issue: issue)

}

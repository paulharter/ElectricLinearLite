//
//  IssueDetail.swift
//  ElectricApp
//
//  Created by Paul Harter on 03/04/2025.
//

import SwiftUI
import ElectricSync

struct IssueDetail: View {
    var issue: Issue
    @StateObject var commentsPublisher: EphemeralShapePublisher<Comment>
    @State private var commentId: Comment.ID? // Single selection.


    var body: some View {
        
        List(){
            Section {
                HStack{
                    Text(issue.title).font(.body)
                }
            }header: {
                Text("Issue \(issue.id.suffix(8))")
            }
            Section {
                HStack{
                    Text("Opened by").font(.footnote).frame(width: 120, alignment: .leading)
                    Text(issue.username).font(.footnote)
                    Spacer()
                }
                HStack{
                    Text("Status").font(.footnote).frame(width: 120, alignment: .leading)
                    Image(issue.statusIcon())
                        .padding(.horizontal)
                        .frame(width: 20, alignment: .center)
                    Text(issue.status.title).font(.footnote)
                    Spacer()
                }
                HStack{
                    Text("Priority").font(.footnote).frame(width: 120, alignment: .leading)
                    Image(issue.priortyIcon())
                        .padding(.horizontal)
                        .frame(width: 20, alignment: .center)
                    Text(issue.priority.title).font(.footnote)
                    Spacer()
                }
                HStack{
                    Text("Created").font(.footnote).frame(width: 120, alignment: .leading)
                    Text(self.formatDate(issue.created!)).font(.footnote)
                    Spacer()
                }
                HStack{
                    Text("Updated").font(.footnote).frame(width: 120, alignment: .leading)
                    Text(self.formatDate(issue.modified!)).font(.footnote)
                    Spacer()
                }
            }
            Section {
                ForEach(commentsPublisher.items){comment in
                    CommentRow(comment: comment)
                }
            }header: {
                Text("Comments")
            }
        }.background(Color(UIColor.systemGroupedBackground))

    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM YYYY - HH:mm"
        return dateFormatter.string(from: date)
    }
}

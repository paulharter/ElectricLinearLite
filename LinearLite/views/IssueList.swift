//
//  IssueList.swift
//  ElectricApp
//
//  Created by Paul Harter on 03/04/2025.
//

import SwiftUI
import SwiftData
import ElectricSync

enum IssueSorting: String, CaseIterable, Identifiable {
    case created
    case updated
    case status
    case priority
    var id: Self { return self }

    var title: String {
        switch self {
            case .created:
                return "Created"
            case .updated:
                return "Updated"
            case .status:
                return "Status"
            case .priority:
                return "Priority"
        }
    }
}

enum IssueSortingDirection: String, CaseIterable, Identifiable {
    case ascending
    case descending
    var id: Self { return self }

    var title: String {
        switch self {
            case .ascending:
                return "Asc"
            case .descending:
                return "Desc"
        }
    }
}

struct IssueList: View {

    @EnvironmentObject var shapeManager: EphemeralShapeManager
    @StateObject var issuesPublisher: EphemeralShapePublisher<Issue>
    @State private var issueId: Issue.ID? // Single selection.
    @State private var selectedSorting = IssueSorting.created
    @State private var selectedDirection = IssueSortingDirection.descending
    @State private var filterPriority: IssuePriority?
    @State private var filterStatus: IssueStatus?
    @State private var busy = false

    var body: some View {
    
        NavigationSplitView {
            VStack{
                HStack{
                    Menu("FILTERS") {
                        Section("Priority") {
                            ForEach(IssuePriority.allCases) { p in
                                Button(p.title) { filterPriority = p  }
                            }
                        }
                        Section("Status") {
                            ForEach(IssueStatus.allCases) { s in
                                Button(s.title) { filterStatus = s  }
                            }
                           }
                    }.textCase(nil).padding(.vertical, 2)
                    Spacer()
                    if(filterPriority == nil && filterStatus == nil){
                        Text("All issues \(issuesPublisher.items.count)").padding(.leading).frame(alignment: .trailing)
                    }
                }.font(.caption)


                if(filterPriority != nil){
                    HStack{
                        HStack{
                            Text("  Priority: \(filterPriority!.title)")
                                .padding(4)
                                .background(Color(red:0.6, green:0.6, blue:0.6))
                                .foregroundColor(.white).textCase(nil)
                            Text(" X ")
                                .padding(4)
                                .background(Color(red:0.4, green:0.4, blue:0.4))
                                .foregroundColor(.white)

                        }
                        .background(Color(red:0.6, green:0.6, blue:0.6))
                            .clipShape(Capsule())
                        Spacer()
                    }.font(.caption).onTapGesture {
                        self.filterPriority = nil
                    }
                }
                if(filterStatus != nil){
                    HStack{
                        HStack{
                            Text("  Status: \(filterStatus!.title)")
                                .padding(4)
                                .background(Color(red:0.6, green:0.6, blue:0.6))
                                .foregroundColor(.white).textCase(nil)
                            Text(" X ")
                                .padding(4)
                                .background(Color(red:0.4, green:0.4, blue:0.4))
                                .foregroundColor(.white)

                        }
                            
                        .background(Color(red:0.6, green:0.6, blue:0.6))
                            .clipShape(Capsule())
                        Spacer()
                    }.font(.caption).onTapGesture {
                        self.filterStatus = nil
                    }

                }
            }.padding(.horizontal, 20).padding(.bottom, 10).background(Color(UIColor.systemGroupedBackground))
            List (selection: $issueId){

                    if busy || issuesPublisher.busy {
                        HStack{
                            Spacer()
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        
                    } else {
                        ForEach(issuesPublisher.items){issue in
                            if (filterPriority == nil && filterStatus == nil) ||
                               (filterPriority == nil && issue.status == filterStatus) ||
                                (filterStatus == nil && issue.priority == filterPriority) ||
                                (issue.status == filterStatus && issue.priority == filterPriority)
                            {
                                IssueRow(issue: issue)
                            }
                        }
                    }

            }.listStyle(PlainListStyle())
            .padding(0)
            .navigationTitle("electric")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Menu {
                            Section("Ordering") {
                                Picker(selectedSorting.title, selection: $selectedSorting) {
                                    ForEach(IssueSorting.allCases) {
                                        Text($0.title)
                                          .tag($0)
                                    }
                                }
                                .pickerStyle(.menu)
                                Picker(selectedDirection.title, selection: $selectedDirection) {
                                    ForEach(IssueSortingDirection.allCases) {
                                        Text($0.title)
                                          .tag($0)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        } label: {
                            //Label("sort", systemImage: "list.bullet")
                            Label("order", systemImage: "arrow.down.circle")
                        }
                    }

                }
        } detail: {
            if issueId != nil {
                if let issue = issuesPublisher.itemForKey(issueId!) {
                    
                    let commentsPublisher: EphemeralShapePublisher<Comment> = self.shapeManager.publisher(table: "comment",
                                                                                                          whereClause: "issue_id='\(issue.id)'",
                                                                          sort: { one, two in
                        return one.created ?? Date() > two.created ?? Date()
                    })
                    IssueDetail(issue: issue, commentsPublisher: commentsPublisher)
                }
            }
        }.onChange(of: selectedSorting) {
            self.busy = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateSorting()
            }
        }.onChange(of: selectedDirection) {
            self.busy = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateSorting()
            }
        }
    }
    
    func updateSorting() {
        
        do{
            try self.issuesPublisher.setSortFunction { lhs, rhs in
                switch (selectedSorting, selectedDirection) {
                case (.created, .descending):
                    return lhs.created ?? Date() > rhs.created ?? Date()
                case (.created, .ascending):
                    return lhs.created ?? Date() < rhs.created ?? Date()
                    
                case (.updated, .descending):
                    return lhs.modified ?? Date() > rhs.modified ?? Date()
                case (.updated, .ascending):
                    return lhs.modified ?? Date() < rhs.modified ?? Date()
                    
                case (.status, .descending):
                    return lhs.status.comparator > rhs.status.comparator
                case (.status, .ascending):
                    return lhs.status.comparator < rhs.status.comparator
                    
                case (.priority, .descending):
                    return lhs.priority.comparator > rhs.priority.comparator
                case (.priority, .ascending):
                    return lhs.priority.comparator < rhs.priority.comparator

                }
            }
        } catch {
        }
        busy = false
    }
}


//#Preview {
//    IssueList()
//}

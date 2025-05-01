//
//  Item.swift
//  ElectricApp
//
//  Created by Paul Harter on 12/11/2024.
//

import Foundation
import ElectricSync


func stringValue(from: [String: Any], key: String) throws -> String {
    guard let value = from[key] as? String else { throw DecodeError.runtimeError("\(key) is missing")}
    return value
}

func dateValue(from: [String: Any], key: String) throws -> Date? {
    guard let isoDate = from[key] as? String else { throw DecodeError.runtimeError("\(key) is missing")}
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")

    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
    
    if let date = formatter.date(from:isoDate){
        return date
    }
    
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
    if let date = formatter.date(from:isoDate){
        return date
    }
    print("failed to parse a date: \(isoDate)")
    return nil
    
}

enum IssueStatus: String, CaseIterable, Codable, Identifiable {
    case canceled, done, backlog, in_progress, todo
    var id: Self { return self }
    
    var comparator: Int {
        switch self {
            case .canceled:
                return 0
            case .done:
                return 1
            case .backlog:
                return 2
            case .in_progress:
                return 3
            case .todo:
                return 4
        }
    }
    
    var title: String {
        switch self {
        case .canceled:
            return "Canceled"
        case .done:
            return "Done"
        case .backlog:
            return "Backlog"
        case .in_progress:
            return "In Progress"
        case .todo:
            return "To Do"
        }
    }
}

enum IssuePriority: String, CaseIterable, Codable, Identifiable {
    case none, low, medium, high, urgent
    var id: Self { return self }
    
    var comparator: Int {
        switch self {
            case .none:
                return 0
            case .low:
                return 1
            case .medium:
                return 2
            case .high:
                return 3
            case .urgent:
                return 4
        }
    }
    
    var title: String {
        switch self {
            case .none:
                return "None"
            case .low:
                return "Low"
            case .medium:
                return "Medium"
            case .high:
                return "High"
            case .urgent:
                return "Urgent"
        }
    }
}

struct Issue: ElectricModel{

    var id: String
    var title: String
    var desc: String
    var priority: IssuePriority
    var created: Date?
    var modified: Date?
    var kanbanorder: String
    var username: String
    var status: IssueStatus
    
    init(from: [String: Any]) throws {
        self.id = try stringValue(from: from, key: "id")
        self.title = try stringValue(from: from, key: "title")
        self.desc = try stringValue(from: from, key: "description")
        let priority = try stringValue(from: from, key: "priority")
        self.priority = IssuePriority(rawValue: priority) ?? .none
        self.kanbanorder = try stringValue(from: from, key: "kanbanorder")
        self.username = try stringValue(from: from, key: "username")
        let status = try stringValue(from: from, key: "status")
        self.status = IssueStatus(rawValue: status) ?? .backlog
        self.created = try dateValue(from: from, key: "created")
        self.modified = try dateValue(from: from, key: "modified")
    }
    
    init(id: String, title: String, desc: String, priority: IssuePriority, created: Date? = nil, modified: Date? = nil, kanbanorder: String, username: String, status: IssueStatus){
        
        self.id = id
        self.title = title
        self.desc = desc
        self.priority = priority
        self.created = created
        self.modified = modified
        self.kanbanorder = kanbanorder
        self.username = username
        self.status = status
    }
    
    func priortyIcon() -> String{
        switch self.priority {
        case .none:
            return "dots"
        case .low:
            return "signal-weak"
        case .medium:
            return "signal-medium"
        case .high:
            return "signal-strong"
        case .urgent:
            return "rounded-claim"
        }
    }
    
    func statusIcon() -> String{
        switch self.status {
        case .backlog:
            return "circle-dot"
        case .canceled:
            return "cancel"
        case .done:
            return "done"
        case .in_progress:
            return "half-circle"
        case .todo:
            return "circle"
        }
    }

    mutating func update(from: [String: Any]) throws -> Bool {

        var changed = false
        
        if let title = from["title"] as? String {
            if self.title != title {
                self.title = title
                changed = true
            }
        }
        
        if let desc = from["description"] as? String {
            if self.desc != desc {
                self.desc = desc
                changed = true
            }
        }
        
        if let priorityString = from["priority"] as? String {
            if let priority = IssuePriority(rawValue: priorityString){
                if self.priority != priority {
                    self.priority = priority
                    changed = true
                }
            }
        }
        
        if let kanbanorder = from["kanbanorder"] as? String {
            if self.kanbanorder != kanbanorder {
                self.kanbanorder = kanbanorder
                changed = true
            }
        }
        
        if let username = from["username"] as? String {
            if self.username != username {
                self.username = username
                changed = true
            }
        }
        
        if let statusString = from["status"] as? String {
            if let status = IssueStatus(rawValue: statusString){
                if self.status != status {
                    self.status = status
                    changed = true
                }
            }
        }
        
        do {
            let created = try dateValue(from: from, key: "created")
            if self.created != created {
                self.created = created
                changed = true
            }
        } catch { }
        
        do {
            let modified = try dateValue(from: from, key: "modified")
            if self.modified != modified {
                self.modified = modified
                changed = true
            }
        } catch {}

        return changed
    }
}




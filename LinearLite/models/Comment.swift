//
//  Comment.swift
//  LinearLite
//
//  Created by Paul Harter on 30/04/2025.
//

import Foundation
import ElectricSync

struct Comment: ElectricModel{

    var id: String
    var body: String
    var username: String
    var issue_id: String
    var created: Date?
    var modified: Date?

    
    init(from: [String: Any]) throws {
        
        self.id = try stringValue(from: from, key: "id")
        self.body = try stringValue(from: from, key: "body")
        self.username = try stringValue(from: from, key: "username")
        self.issue_id = try stringValue(from: from, key: "issue_id")
        self.created = try dateValue(from: from, key: "created")
        self.modified = try dateValue(from: from, key: "modified")
    }
    
    init(_ id: String, _ body: String, _ username: String, _ issue_id: String, _ created: Date? = nil, _ modified: Date? = nil) {
        self.id = id
        self.body = body
        self.username = username
        self.issue_id = issue_id
        self.created = created
        self.modified = modified
    }
    

    mutating func update(from: [String: Any]) throws -> Bool {

        var changed = false
        if let body = from["body"] as? String {
            if self.body != body {
                self.body = body
                changed = true
            }
        }
        
        if let username = from["username"] as? String {
            if self.username != username {
                self.username = username
                changed = true
            }
        }

        if let issue_id = from["issue_id"] as? String {
            if self.issue_id != issue_id {
                self.issue_id = issue_id
                changed = true
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

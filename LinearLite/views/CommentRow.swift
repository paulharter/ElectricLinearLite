//
//  CommentRow.swift
//  LinearLite
//
//  Created by Paul Harter on 30/04/2025.
//

import SwiftUI
//import UIKit

struct CommentRow: View {
    var comment: Comment


    var body: some View {
        VStack{
            HStack{
                Text(comment.username).font(.caption).foregroundColor(.gray)
                Spacer()
                Text(formatDate(comment.created!)).font(.caption).foregroundColor(.gray)
            }
            HStack{
                Text(comment.body).font(.body).frame(alignment: .leading)
                Spacer()
            }
        }
    }
}

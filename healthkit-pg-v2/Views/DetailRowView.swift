//
//  DetailRowView.swift
//  healthkit-pg-v2
//
//  Created by Fahrel Gibran on 05/05/25.
//

// Views/DetailRowView.swift
import SwiftUI

struct DetailRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

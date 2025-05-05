//
//  StatRowView.swift
//  healthkit-pg-v2
//
//  Created by Fahrel Gibran on 05/05/25.
//

// Views/StatRowView.swift
import SwiftUI

struct StatRowView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 20))
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

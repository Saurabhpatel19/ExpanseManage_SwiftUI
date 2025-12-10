//
//  CategoryChip.swift
//  DeveloperHub
//
//  Created by Saurabh on 10/12/25.
//


// Features/Expenses/Views/Components/CategoryChip.swift
import SwiftUI

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    isSelected
                    ? Color.blue.opacity(0.2)
                    : Color.gray.opacity(0.15)
                )
                .cornerRadius(12)
        }
        .foregroundColor(.primary)
    }
}

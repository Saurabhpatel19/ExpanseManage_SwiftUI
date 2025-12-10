//
//  ExpenseCategory.swift
//  DeveloperHub
//
//  Created by Saurabh on 01/12/25.
//


import Foundation
import SwiftUI

enum ExpenseCategory: String, CaseIterable, Codable, Identifiable {
    var id: String { rawValue }
    
    case food = "Food"
    case transport = "Transport"
    case utilities = "Utilities"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case other = "Other"
}

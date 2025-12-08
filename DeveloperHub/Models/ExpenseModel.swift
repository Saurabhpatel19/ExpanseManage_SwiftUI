//
//  ExpenseModel.swift
//  DeveloperHub
//
//  Created by Saurabh on 08/12/25.
//


import SwiftData
import Foundation

@Model
class ExpenseModel {
    var title: String
    var category: String
    var amount: Double
    var date: Date

    init(title: String, category: String, amount: Double, date: Date) {
        self.title = title
        self.category = category
        self.amount = amount
        self.date = date
    }
}

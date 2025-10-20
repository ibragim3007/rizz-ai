//
//  PlanBuilders.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/20/25.
//

import RevenueCat
import Foundation


enum Plan: String, CaseIterable {
    case annual
    case weekly
    case monthly
}

// Build subtitle so that billed price per period is first and prominent,
// and per-week breakdown appears only for periods longer than a week.
func dynamicSubtitle(for plan: Plan, package: (_ for: Plan) -> Package?) -> String {
    guard let pkg = package(plan) else {
        // Fallbacks (keep billed-first to remain compliant if we lack live data)
        switch plan {
        case .annual:
            return "$XX.XX / year ≈ $YY.YY /week"
        case .weekly:
            return "$X.XX / week"
        case .monthly:
            return "$X.XX / monthly"
        }
    }
    
    let product = pkg.storeProduct
    
    // Billed price (localized currency string + period)
    let billed = billedPriceString(for: product)
    
    // If the product bills weekly, no per-week breakdown needed (already weekly).
    if let period = product.subscriptionPeriod,
       period.unit == .week {
        return billed
    }
    
    // For periods longer than a week, add a per-week breakdown on the next line.
    if let perWeek = pricePerWeekString(for: product) {
        return "\(billed) ≈ \(perWeek) / week"
    } else {
        return billed
    }
}



// Billed price per actual period, e.g. "$29.99 / year" or "$4.99 / month"
func billedPriceString(for product: StoreProduct) -> String {
    let base = product.localizedPriceString
    guard let period = product.subscriptionPeriod else {
        return base
    }
    
    let unitString: String
    switch period.unit {
    case .day:
        unitString = period.value == 1 ? "day" : "\(period.value) days"
    case .week:
        unitString = period.value == 1 ? "week" : "\(period.value) weeks"
    case .month:
        unitString = period.value == 1 ? "month" : "\(period.value) months"
    case .year:
        unitString = period.value == 1 ? "year" : "\(period.value) years"
    @unknown default:
        unitString = "period"
    }
    
    return "\(base) / \(unitString)"
}

func pricePerWeekString(for product: StoreProduct) -> String? {
    guard let period = product.subscriptionPeriod else { return nil }
    // If already weekly, caller should not show breakdown
    guard period.unit != .week else { return nil }
    
    let priceDecimal = product.price as NSDecimalNumber
    
    // Compute the duration of the subscription period using Calendar
    let calendar = Calendar(identifier: .gregorian)
    let start = Date()
    var comps = DateComponents()
    switch period.unit {
    case .day:
        comps.day = period.value
    case .week:
        comps.day = period.value * 7
    case .month:
        comps.month = period.value
    case .year:
        comps.year = period.value
    @unknown default:
        return nil
    }
    guard let end = calendar.date(byAdding: comps, to: start) else { return nil }
    let seconds = end.timeIntervalSince(start)
    let weeks = seconds / (7 * 24 * 60 * 60)
    guard weeks > 0 else { return nil }
    
    let divisor = NSDecimalNumber(value: weeks)
    let perWeek = priceDecimal.dividing(by: divisor)
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = product.currencyCode
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 0
    
    return formatter.string(from: perWeek)
}

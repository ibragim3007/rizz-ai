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
// For weekly plan: if there is an introductory offer (free trial or intro price)
// show it explicitly, e.g. "First X days free, then Y / week" or
// "First N weeks at A/week, then B / week".
func dynamicSubtitle(for plan: Plan, package: (_ for: Plan) -> Package?) -> String {
    guard let pkg = package(plan) else {
        // Fallbacks (keep billed-first to remain compliant if we lack live data)
        switch plan {
        case .annual:
            return "$XX.XX / year ≈ $YY.YY / week"
        case .weekly:
            return "$X.XX / week"
        case .monthly:
            return "$X.XX / month"
        }
    }
    
    let product = pkg.storeProduct
    
    // Special handling for weekly plan: prefer showing introductory offer if available.
    if plan == .weekly, let offerText = weeklyIntroOfferSubtitle(for: product) {
        return offerText
    }
    
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
    
    return "\(base) / \(periodUnitString(period.unit, count: period.value))"
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

// MARK: - Weekly intro offer rendering

// Returns a subtitle that prioritizes the introductory offer for weekly products.
// Examples:
// - "First 7 days free, then $4.99 / week"
// - "First 1 week at $0.99 / week, then $4.99 / week"
// - "First 4 weeks for $2.99, then $4.99 / week"
private func weeklyIntroOfferSubtitle(for product: StoreProduct) -> String? {
    guard let intro = product.introductoryDiscount else { return nil }
    
    // Base "then" price: show per billed period (for weekly product it's "/ week").
    let thenPrice: String = {
        if let period = product.subscriptionPeriod {
            return "\(product.localizedPriceString) / \(periodUnitString(period.unit, count: period.value))"
        } else {
            return product.localizedPriceString
        }
    }()
    
    // Derive total intro duration and wording.
    let totalIntro = totalIntroPeriod(intro)
    
    switch intro.paymentMode {
    case .freeTrial:
        // "First X days free, then Y / week"
        let firstPart = "First \(totalIntro.countDescription) free"
        return "\(firstPart), then \(thenPrice)"
        
    case .payAsYouGo:
        // Price applies per each intro period cycle.
        // If the unit is week, use "at A / week"; otherwise "at A".
        let introPrice = intro.localizedPriceString
        let atPart: String
        if intro.subscriptionPeriod.unit == .week && intro.subscriptionPeriod.value == 1 {
            atPart = "\(introPrice)"
        } else {
            atPart = "at \(introPrice)"
        }
        // "First N weeks at A / week, then Y / week"
        let firstPart = "First \(totalIntro.countDescription) \(atPart)"
        return "\(firstPart), then \(thenPrice)"
        
    case .payUpFront:
        // One upfront price for the whole intro duration.
        // "First N weeks for A, then Y / week"
        let firstPart = "First \(totalIntro.countDescription) for \(intro.localizedPriceString)"
        return "\(firstPart), then \(thenPrice)"
        
    @unknown default:
        return nil
    }
}

// Compute total intro duration: subscriptionPeriod * numberOfPeriods,
// returning a convenient textual description ("7 days", "3 weeks", "1 month", etc.).
private func totalIntroPeriod(_ intro: StoreProductDiscount) -> (unit: SubscriptionPeriod.Unit, value: Int, countDescription: String) {
    let unit = intro.subscriptionPeriod.unit
    let valuePerCycle = intro.subscriptionPeriod.value
    let cycles = max(intro.numberOfPeriods, 1)
    
    // Multiply value by number of cycles in the same unit.
    let totalValue = valuePerCycle * cycles
    
    // Optionally, you could normalize days -> weeks if divisible by 7, but
    // keeping original unit is often clearer and matches App Store Connect setup.
    let description = periodUnitString(unit, count: totalValue)
    return (unit, totalValue, description)
}

// English pluralization for period units.
private func periodUnitString(_ unit: SubscriptionPeriod.Unit, count: Int) -> String {
    switch unit {
    case .day:
        return count == 1 ? "day" : "\(count) days"
    case .week:
        return count == 1 ? "week" : "\(count) weeks"
    case .month:
        return count == 1 ? "month" : "\(count) months"
    case .year:
        return count == 1 ? "year" : "\(count) years"
    @unknown default:
        return "period"
    }
}

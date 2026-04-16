//
//  HairCareRoutine.swift
//  hairInsightTesting
//
//  Created by Avnish Singh on 4/16/26.
//


import Foundation

// MARK: - Hair Care Routine
struct HairCareRoutine: Codable, Identifiable {
    let id: UUID
    let cardHeading: String?
    let summary: String?
    let applyingFrequency: String?
    let iconName: String?
    let durationWeeks: Int?
    let difficultyLevel: String?
    let estimatedTimeMinutes: Int?
    let steps: [RoutineStep]?
    let productsNeeded: [ProductNeeded]?
    let isActive: Bool?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, summary
        case cardHeading        = "card_heading"
        case applyingFrequency  = "applying_frequency"
        case iconName           = "icon_name"
        case durationWeeks      = "duration_weeks"
        case difficultyLevel    = "difficulty_level"
        case estimatedTimeMinutes = "estimated_time_minutes"
        case steps
        case productsNeeded     = "products_needed"
        case isActive           = "is_active"
        case createdAt          = "created_at"
    }

    var title: String { cardHeading ?? "Routine" }
}

struct RoutineStep: Codable, Identifiable {
    var id = UUID()
    let step: Int?
    let title: String?
    let instruction: String?
    let tip: String?
    enum CodingKeys: String, CodingKey { case step, title, instruction, tip }
}

struct ProductNeeded: Codable, Identifiable {
    var id = UUID()
    let name: String?
    let optional: Bool?
    enum CodingKeys: String, CodingKey { case name, optional }
}

// MARK: - Care Tip
struct CareTip: Codable, Identifiable {
    let id: UUID
    let title: String?
    let tipDescription: String?
    let frequency: String?
    let benefits: String?
    let howToUse: [UsageStep]?
    let imageUrl: String?
    let mediaUrl: String?
    let whatToAvoid: String?
    let precautions: String?
    let sourceName: String?
    let sourceUrl: String?
    let sourceType: String?
    let isActive: Bool?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, frequency, benefits, precautions
        case tipDescription = "tip_description"
        case howToUse       = "how_to_use"
        case imageUrl       = "image_url"
        case mediaUrl       = "media_url"
        case whatToAvoid    = "what_to_avoid"
        case sourceName     = "source_name"
        case sourceUrl      = "source_url"
        case sourceType     = "source_type"
        case isActive       = "is_active"
        case createdAt      = "created_at"
    }

    var imageKey: String { imageUrl ?? mediaUrl ?? "" }
}

// MARK: - Home Remedy
struct HomeRemedy: Codable, Identifiable {
    let id: UUID
    let title: String?
    let remedyDescription: String?
    let frequency: String?
    let benefits: String?
    let ingredients: [Ingredient]?
    let howToMake: [UsageStep]?
    let howToApply: [UsageStep]?
    let thumbnailUrl: String?
    let mediaUrl: String?
    let leaveonDurationMinutes: Int?
    let whatToAvoid: String?
    let precautions: String?
    let sourceName: String?
    let sourceUrl: String?
    let sourceType: String?
    let isActive: Bool?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, frequency, benefits, ingredients, precautions
        case remedyDescription      = "remedy_description"
        case howToMake              = "how_to_make"
        case howToApply             = "how_to_apply"
        case thumbnailUrl           = "thumbnail_url"
        case mediaUrl               = "media_url"
        case leaveonDurationMinutes = "leave_on_duration_minutes"
        case whatToAvoid            = "what_to_avoid"
        case sourceName             = "source_name"
        case sourceUrl              = "source_url"
        case sourceType             = "source_type"
        case isActive               = "is_active"
        case createdAt              = "created_at"
    }

    var imageKey: String { thumbnailUrl ?? mediaUrl ?? "" }
}

struct Ingredient: Codable, Identifiable {
    var id = UUID()
    let name: String?
    let quantity: String?
    let unit: String?
    let notes: String?
    enum CodingKeys: String, CodingKey { case name, quantity, unit, notes }
}

struct UsageStep: Codable, Identifiable {
    var id = UUID()
    let step: Int?
    let title: String?
    let instruction: String?
    enum CodingKeys: String, CodingKey { case step, title, instruction }
}

// MARK: - Frequency Formatter
func fmtFreq(_ f: String?) -> String {
    let map: [String: String] = [
        "daily":                          "Every day",
        "twice_weekly":                   "Twice a week",
        "weekly":                         "Once a week",
        "each_wash":                      "Every wash",
        "nightly":                        "Every night",
        "as_needed":                      "As needed",
        "weekly_routine":                 "Weekly routine",
        "daily_with_weekly_treatments":   "Daily + weekly",
        "weekly_treatment_plan":          "Weekly plan",
    ]
    guard let f else { return "" }
    return map[f] ?? f.replacingOccurrences(of: "_", with: " ").capitalized
}

// MARK: - Image URL map (media_url key → Unsplash)
let imageMap: [String: String] = [
    "oil_massage_thumb":      "https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?w=500&q=80",
    "oil_massage_banner":     "https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?w=700&q=80",
    "silk_pillowcase_thumb":  "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=500&q=80",
    "silk_pillowcase_banner": "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=700&q=80",
    "cold_water_rinse_thumb": "https://images.unsplash.com/photo-1560066984-138daaa4e4e1?w=500&q=80",
    "scalp_massage_thumb":    "https://images.unsplash.com/photo-1560750588-73207b1ef5b8?w=500&q=80",
    "night_wrap_thumb":       "https://images.unsplash.com/photo-1576426863848-c21f53c60b19?w=500&q=80",
    "aloevera_mask_thumb":    "https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=500&q=80",
    "onion_juice_thumb":      "https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=500&q=80",
    "egg_mask_thumb":         "https://images.unsplash.com/photo-1607631568010-a87245c0daf8?w=500&q=80",
    "rice_water_thumb":       "https://images.unsplash.com/photo-1536304929831-ee1ca9d44906?w=500&q=80",
    "fenugreek_mask_thumb":   "https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=500&q=80",
]

let fallbackImageURL = "https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=500&q=80"

func resolvedImageURL(_ key: String?) -> URL? {
    guard let key, !key.isEmpty else { return URL(string: fallbackImageURL) }
    if key.hasPrefix("http") { return URL(string: key) }
    return URL(string: imageMap[key] ?? fallbackImageURL)
}
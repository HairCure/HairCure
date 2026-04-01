//
//  MindEaseModel.swift
//
//  Pure data models for the MindEase feature.
//  No logic, no computed properties, no SwiftUI.

import Foundation

// MARK: - Category

struct MindEaseCategory: Identifiable, Hashable {
    let id: UUID
    var title: String
    var categoryDescription: String
    var cardImageUrl: String
    var cardIconName: String
}

// MARK: - Category Content

struct MindEaseCategoryContent: Identifiable, Hashable {
    let id: UUID
    var categoryId: UUID
    var title: String
    var caption: String
    var mediaURL: String
    var mediaType: String
    var durationSeconds: Int
    var difficultyLevel: String
    var imageurl: String
}

// MARK: - Mindful Session

struct MindfulSession: Identifiable, Hashable {
    let id: UUID
    var userId: UUID
    var contentId: UUID
    var sessionDate: Date
    var minutesCompleted: Int
    var startTime: Date
    var endTime: Date
}

// MARK: - Today's Plan

struct TodaysPlan: Identifiable, Hashable {
    let id: UUID
    var userId: UUID
    var planDate: Date
    var contentId: UUID
    var categoryId: UUID
    var planId: String
    var minutesTarget: Int
    var minutesCompleted: Int
    var isCompleted: Bool
}

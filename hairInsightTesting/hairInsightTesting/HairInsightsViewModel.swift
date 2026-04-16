//
//  HairInsightsViewModel.swift
//  hairInsightTesting
//
//  Created by Avnish Singh on 4/16/26.
//


import SwiftUI
import Observation
@Observable
@MainActor
final class HairInsightsViewModel {
    var routines:  [HairCareRoutine] = []
    var tips:      [CareTip]         = []
    var remedies:  [HomeRemedy]      = []
    var status:    LoadStatus        = .loading
    var errorMsg:  String            = ""
    var favourites: Set<UUID>        = []

    enum LoadStatus { case loading, ok, error }

    func load() async {
        status = .loading
        do {
            async let r: [HairCareRoutine] = Supabase.fetch("hair_care_routines")
            async let c: [CareTip]         = Supabase.fetch("care_tips")
            async let h: [HomeRemedy]      = Supabase.fetch("home_remedies")
            let (routines, tips, remedies) = try await (r, c, h)
            self.routines = routines
            self.tips     = tips
            self.remedies = remedies
            status = .ok
        } catch {
            errorMsg = error.localizedDescription
            status   = .error
        }
    }

    func toggleFav(_ id: UUID) {
        if favourites.contains(id) { favourites.remove(id) } else { favourites.insert(id) }
    }

    var favTips:     [CareTip]     { tips.filter     { favourites.contains($0.id) } }
    var favRemedies: [HomeRemedy]  { remedies.filter { favourites.contains($0.id) } }
}

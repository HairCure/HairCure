////
////  Supabase.swift
////  hairInsightTesting
////
////  Created by Avnish Singh on 4/16/26.
////
//
//
//import Foundation
//import SwiftUI
//
//// MARK: - Supabase Config
//enum Supabase {
//    static let url    = "https://rhpvhgpeanhdbsfhhtsc.supabase.co"
//    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJocHZoZ3BlYW5oZGJzZmhodHNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NDkwMzYsImV4cCI6MjA5MTAyNTAzNn0.8eku6QGfvILBGHo84mVfe15em1icnKxXx-Y3G4oz2W0"
//
//    static var headers: [String: String] {
//        ["apikey": anonKey, "Authorization": "Bearer \(anonKey)", "Content-Type": "application/json"]
//    }
//
////    static func fetch<T: Decodable>(_ table: String) async throws -> [T] {
////        var comps = URLComponents(string: "\(url)/rest/v1/\(table)")!
////        comps.queryItems = [
////            URLQueryItem(name: "select",    value: "*"),        // ← MOVE THIS FIRST
////            URLQueryItem(name: "is_active", value: "eq.true"),
////            URLQueryItem(name: "order",     value: "created_at.asc"),
////        ]
////        var req = URLRequest(url: comps.url!)
////        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
////        let (data, resp) = try await URLSession.shared.data(for: req)
////        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
////            throw URLError(.badServerResponse)
////        }
////        return try JSONDecoder().decode([T].self, from: data)
////    }
//    
//    static func fetch<T: Decodable>(_ table: String) async throws -> [T] {
//        var comps = URLComponents(string: "\(url)/rest/v1/\(table)")!
//        comps.queryItems = [
//            URLQueryItem(name: "select",    value: "*"),
//            URLQueryItem(name: "is_active", value: "eq.true"),
//            URLQueryItem(name: "order",     value: "created_at.asc"),
//        ]
//        var req = URLRequest(url: comps.url!)
//        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
//        
//        let (data, resp) = try await URLSession.shared.data(for: req)
//        
//        // DEBUG - print everything
//        let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? -1
//        let responseString = String(data: data, encoding: .utf8) ?? "nil"
//        print("🔴 TABLE: \(table)")
//        print("🔴 URL: \(comps.url!)")
//        print("🔴 STATUS: \(statusCode)")
//        print("🔴 RESPONSE: \(responseString)")
//        
//        guard statusCode == 200 else {
//            throw URLError(.badServerResponse)
//        }
//        return try JSONDecoder().decode([T].self, from: data)
//    }
//}
////
////// MARK: - Design Tokens
////extension Color {
////    static let hiBackground = Color(hex: "#EDE8DF")
////    static let hiCard       = Color.white
////    static let hiInk        = Color(hex: "#1A1A18")
////    static let hiMuted      = Color(hex: "#8A8278")
////    static let hiAccent     = Color(hex: "#7C4F2A")
////    static let hiWarm       = Color(hex: "#E4DDD3")
////    static let hiBorder     = Color(hex: "#DDD7CE")
////    static let hiRed        = Color(hex: "#D96B5A")
////    static let hiLavBg      = Color(hex: "#ECEAF5")
////    static let hiLavTxt     = Color(hex: "#9090A8")
////}
////
////extension Color {
////    init(hex: String) {
////        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
////        var val: UInt64 = 0
////        Scanner(string: h).scanHexInt64(&val)
////        let r = Double((val >> 16) & 0xFF) / 255
////        let g = Double((val >>  8) & 0xFF) / 255
////        let b = Double( val        & 0xFF) / 255
////        self.init(red: r, green: g, blue: b)
////    }
////}

//
//  Supabase.swift
//  hairInsightTesting
//
//  Created by Avnish Singh on 4/16/26.
//

import Foundation
import SwiftUI

// MARK: - Supabase Config
enum Supabase {
    static let url    = "https://mxufmlnvcogvbzvejzxs.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im14dWZtbG52Y29ndmJ6dmVqenhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYzMzAwMjcsImV4cCI6MjA5MTkwNjAyN30.2P1xAbBhKWt9GFS9U3db5tU3koh2pv1GukMrI3qxggQ"

    static var headers: [String: String] {
        ["apikey": anonKey, "Authorization": "Bearer \(anonKey)", "Content-Type": "application/json"]
    }

//    static func fetch<T: Decodable>(_ table: String) async throws -> [T] {
//        var comps = URLComponents(string: "\(url)/rest/v1/\(table)")!
//        comps.queryItems = [
//            URLQueryItem(name: "select", value: "*"),
//            URLQueryItem(name: "order",  value: "created_at.asc"),
//            // is_active filter removed — RLS policy already handles this server-side
//        ]
//        var req = URLRequest(url: comps.url!)
//        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
//        let (data, resp) = try await URLSession.shared.data(for: req)
//        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
//            throw URLError(.badServerResponse)
//        }
//        return try JSONDecoder().decode([T].self, from: data)
//    }
    static func fetch<T: Decodable>(_ table: String) async throws -> [T] {
        var comps = URLComponents(string: "\(url)/rest/v1/\(table)")!
        comps.queryItems = [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "order",  value: "created_at.asc"),
        ]
        var req = URLRequest(url: comps.url!)
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        // DEBUG
        let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? -1
        let responseString = String(data: data, encoding: .utf8) ?? "nil"
        print("🔴 TABLE: \(table)")
        print("🔴 STATUS: \(statusCode)")
        print("🔴 RESPONSE: \(responseString)")
        
        guard statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([T].self, from: data)
    }
}

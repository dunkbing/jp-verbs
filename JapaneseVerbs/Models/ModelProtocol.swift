//
//  ModelProtocol.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//


import Foundation

// This file provides backwards compatibility for SwiftData models
// when running on iOS 15/macOS 12

// Protocol-based model for backward compatibility
protocol ModelProtocol {
    var id: String { get }
    var isSelected: Bool { get set }
}

// Backwards compatible Verb model
struct LegacyVerb: Identifiable, Codable, ModelProtocol {
    var id: String
    var verbClass: String
    var stem: String
    var teForm: String
    var infinitive: String
    var romaji: String
    
    // Present indicative
    var presentIndicativePlainPositive: [String]
    var presentIndicativePlainNegative: [String]
    var presentIndicativePolitePositive: [String]
    var presentIndicativePoliteNegative: [String]
    var presentIndicativeMeaningPositive: String
    var presentIndicativeMeaningNegative: String
    
    // Past indicative
    var pastIndicativePlainPositive: [String]
    var pastIndicativePlainNegative: [String]
    var pastIndicativePolitePositive: [String]
    var pastIndicativePoliteNegative: [String]
    
    // Te form related
    var presentProgressivePlainPositive: [String]
    var presentProgressivePolitePositive: [String]
    var presentProgressivePoliteNegative: [String]
    
    var isSelected: Bool = false
    
    init(from verbJSON: Verb.VerbJSON) {
        self.id = verbJSON.id
        self.verbClass = verbJSON.class
        self.stem = verbJSON.stem
        self.teForm = verbJSON.te_form
        self.infinitive = verbJSON.infinitive
        self.romaji = verbJSON.romaji
        self.presentIndicativePlainPositive = verbJSON.present_indicative.plain.positive
        self.presentIndicativePlainNegative = verbJSON.present_indicative.plain.negative
        self.presentIndicativePolitePositive = verbJSON.present_indicative.polite.positive
        self.presentIndicativePoliteNegative = verbJSON.present_indicative.polite.negative
        self.presentIndicativeMeaningPositive = verbJSON.present_indicative.meaning.positive
        self.presentIndicativeMeaningNegative = verbJSON.present_indicative.meaning.negative
        self.pastIndicativePlainPositive = verbJSON.past_indicative.plain.positive
        self.pastIndicativePlainNegative = verbJSON.past_indicative.plain.negative
        self.pastIndicativePolitePositive = verbJSON.past_indicative.polite.positive
        self.pastIndicativePoliteNegative = verbJSON.past_indicative.polite.negative
        self.presentProgressivePlainPositive = verbJSON.present_progressive?.plain.positive ?? []
        self.presentProgressivePolitePositive = verbJSON.present_progressive?.polite.positive ?? []
        self.presentProgressivePoliteNegative = verbJSON.present_progressive?.polite.negative ?? []
    }
}

// Mock ModelContext for backward compatibility
class MockModelContext {
    private var storage: [String: Any] = [:]
    
    func insert<T: ModelProtocol>(_ model: T) {
        storage[model.id] = model
    }
    
    func delete<T: ModelProtocol>(_ model: T) {
        storage.removeValue(forKey: model.id)
    }
    
    func save() throws {
        // In the mock implementation, we don't need to do anything
    }
}

// Backwards compatibility for ViewModifier
import SwiftUI

struct ModelContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        if isCompatibleWithSwiftData {
            // This would use real SwiftData if available
            return AnyView(content)
        } else {
            // Legacy implementation
            return AnyView(content)
        }
    }
}

extension View {
    func withModelContainer() -> some View {
        self.modifier(ModelContainerModifier())
    }
}

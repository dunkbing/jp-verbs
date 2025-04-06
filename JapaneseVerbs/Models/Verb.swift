//
//  Verb.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import Foundation
import SwiftData

@Model
final class Verb: Identifiable {
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
    
    // Add more properties for the complete verb conjugation
    var isSelected: Bool = false
    
    init(id: String, verbClass: String, stem: String, teForm: String, infinitive: String, romaji: String,
         presentIndicativePlainPositive: [String], presentIndicativePlainNegative: [String],
         presentIndicativePolitePositive: [String], presentIndicativePoliteNegative: [String],
         presentIndicativeMeaningPositive: String, presentIndicativeMeaningNegative: String,
         pastIndicativePlainPositive: [String], pastIndicativePlainNegative: [String],
         pastIndicativePolitePositive: [String], pastIndicativePoliteNegative: [String],
         presentProgressivePlainPositive: [String], presentProgressivePolitePositive: [String],
         presentProgressivePoliteNegative: [String]) {
        self.id = id
        self.verbClass = verbClass
        self.stem = stem
        self.teForm = teForm
        self.infinitive = infinitive
        self.romaji = romaji
        self.presentIndicativePlainPositive = presentIndicativePlainPositive
        self.presentIndicativePlainNegative = presentIndicativePlainNegative
        self.presentIndicativePolitePositive = presentIndicativePolitePositive
        self.presentIndicativePoliteNegative = presentIndicativePoliteNegative
        self.presentIndicativeMeaningPositive = presentIndicativeMeaningPositive
        self.presentIndicativeMeaningNegative = presentIndicativeMeaningNegative
        self.pastIndicativePlainPositive = pastIndicativePlainPositive
        self.pastIndicativePlainNegative = pastIndicativePlainNegative
        self.pastIndicativePolitePositive = pastIndicativePolitePositive
        self.pastIndicativePoliteNegative = pastIndicativePoliteNegative
        self.presentProgressivePlainPositive = presentProgressivePlainPositive
        self.presentProgressivePolitePositive = presentProgressivePolitePositive
        self.presentProgressivePoliteNegative = presentProgressivePoliteNegative
    }
}

// Extension for decoding from JSON
extension Verb {
    struct VerbJSON: Codable {
        let id: String
        let `class`: String
        let stem: String
        let te_form: String
        let infinitive: String
        let romaji: String
        let present_indicative: ConjugationSection
        let past_indicative: ConjugationSection
        let present_progressive: ConjugationSection?

        struct ConjugationSection: Codable {
            let plain: ConjugationOptions
            let polite: ConjugationOptions
            let meaning: ConjugationMeaning
            
            struct ConjugationOptions: Codable {
                let positive: [String]
                let negative: [String]
            }
            
            struct ConjugationMeaning: Codable {
                let positive: String
                let negative: String
            }
        }
    }
    
    static func fromJSON(_ json: VerbJSON) -> Verb {
        return Verb(
            id: json.id,
            verbClass: json.class,
            stem: json.stem,
            teForm: json.te_form,
            infinitive: json.infinitive,
            romaji: json.romaji,
            presentIndicativePlainPositive: json.present_indicative.plain.positive,
            presentIndicativePlainNegative: json.present_indicative.plain.negative,
            presentIndicativePolitePositive: json.present_indicative.polite.positive,
            presentIndicativePoliteNegative: json.present_indicative.polite.negative,
            presentIndicativeMeaningPositive: json.present_indicative.meaning.positive,
            presentIndicativeMeaningNegative: json.present_indicative.meaning.negative,
            pastIndicativePlainPositive: json.past_indicative.plain.positive,
            pastIndicativePlainNegative: json.past_indicative.plain.negative,
            pastIndicativePolitePositive: json.past_indicative.polite.positive,
            pastIndicativePoliteNegative: json.past_indicative.polite.negative,
            presentProgressivePlainPositive: json.present_progressive?.plain.positive ?? [],
            presentProgressivePolitePositive: json.present_progressive?.polite.positive ?? [],
            presentProgressivePoliteNegative: json.present_progressive?.polite.negative ?? []
        )
    }
}

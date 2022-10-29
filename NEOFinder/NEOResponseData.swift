//
//  NEOData.swift
//  NEOFinder
//
//  Created by Gobinath on 29/10/22.
//

import Foundation

struct NEOResponse : Codable {
    let links: Links
    let elementCount: Int
    let nearEarthObjects: [String: [Asteriod]]
    
    enum CodingKeys: String, CodingKey {
        case links
        case elementCount = "element_count"
        case nearEarthObjects = "near_earth_objects"
    }
}

struct Links: Codable {
    let prev: String?
    let next: String?
    let current: String
    
    enum CodingKeys: String, CodingKey {
        case prev
        case next
        case current = "self"
    }
}

struct Asteriod: Codable {
    let id: String
    let name: String
    let neoReferenceId: String
    let nasaJPLUrl: String
    let absoluteMagnitude: Double
    let estimatedDiameter: EstimatedDiameter
    let isPotentiallyHazardousAsteriod: Bool
    let closeApproachData: [CloseApproachData]
    let isSentryObject: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case neoReferenceId = "neo_reference_id"
        case nasaJPLUrl = "nasa_jpl_url"
        case absoluteMagnitude = "absolute_magnitude_h"
        case estimatedDiameter = "estimated_diameter"
        case isPotentiallyHazardousAsteriod = "is_potentially_hazardous_asteroid"
        case closeApproachData = "close_approach_data"
        case isSentryObject = "is_sentry_object"
    }
}

struct EstimatedDiameter: Codable {
    let kilometers: Diameter
    
    func toString() -> String {
        return "[\(kilometers.toString())]" + " kilometers"
    }
}

struct Diameter: Codable {
    let minEstimatedDiameter: Double
    let maxEstimatedDiameter: Double
    
    enum CodingKeys: String, CodingKey {
        case minEstimatedDiameter = "estimated_diameter_min"
        case maxEstimatedDiameter = "estimated_diameter_max"
    }
    
    func toString() -> String {
        return String(format: "Min: %.2f - Max: %.2f", minEstimatedDiameter, maxEstimatedDiameter)
    }
}

struct CloseApproachData: Codable {
    let closeApproachDate: String
    let closeApproachDateFull: String?
    let epochDateCloseApproach: Int64
    let relativeVelocity: RelativeVelocity
    let missDistance: MissDistance
    let orbitingBody: String
    
    enum CodingKeys: String, CodingKey {
        case closeApproachDate = "close_approach_date"
        case closeApproachDateFull = "close_approach_date_full"
        case epochDateCloseApproach = "epoch_date_close_approach"
        case relativeVelocity = "relative_velocity"
        case missDistance = "miss_distance"
        case orbitingBody = "orbiting_body"
    }
}

struct RelativeVelocity: Codable {
    let kmPerSecond: String
    let kmPerHour: String
    let milesPerHour: String

    enum CodingKeys: String, CodingKey {
        case kmPerSecond = "kilometers_per_second"
        case kmPerHour = "kilometers_per_hour"
        case milesPerHour = "miles_per_hour"
    }

    func toString() -> String {
        return String(format: "%.2f kilometers/hour", Double(kmPerHour)!)
    }
}

struct MissDistance: Codable {
    let astronomical: String
    let lunar: String
    let kilometers: String
    let miles: String
    
    func toString() -> String {
        return String(format: "%.2f kilometers", Double(kilometers)!)
    }
}


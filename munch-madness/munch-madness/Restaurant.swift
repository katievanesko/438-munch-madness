//
//  Venue.swift
//  munch-madness
//
//  Created by Tristan Senkowski on 11/22/20.
//  Copyright © 2020 Katie Vanesko. All rights reserved.
//

import Foundation

//struct Restaurant {
//    var name      : String?
//    var id        : String?
//    var rating    : Float?
//    var price     : String?
//    var location  : String?
//    var distance  : Double?
//    var radius    : Int?
//    var address   : String?
//    var image_url : String?
//}
struct YelpAPIResult: Decodable {
    var businesses: [Restaurant]
    var region: APIRegion
    var total: Int
    
}

//struct Restaurant: Decodable {
//    var id: String
//    var alias: String
//    var name: String
//    var image_url: String
//    var is_closed: Bool
//    var url: String
//    var review_count: Int
//    var categories: [Category]
//    var rating: Double
//    var coordinates: Coordinate
//    var transactions: [String]
//    var price: String
//    var location: Location
//    var phone: String
//    var display_phone: String
//    var distance: Float
//
//
//}
struct Restaurant: Decodable {
    var alias: String?
    var categories: [Category]
    var coordinates: Coordinate
    var display_phone: String?
    var distance: Float
    var id: String
    var image_url: String?
    var is_closed: Bool
    var location: Location
    var name: String
    var phone: String?
    var price: String
    var rating: Double
    var review_count: Int?
    var transactions: [String?]
    var url: String?
}

struct Category: Decodable {
    var alias: String
    var title: String
}

struct Coordinate: Decodable {
    var latitude: Float
    var longitude: Float
}


struct Location: Decodable {
    var address1: String
    var address2: String?
    var address3: String?
    var city: String
    var zip_code: String
    var country: String
    var state: String
    var display_address: [String?]
}

struct APIRegion: Decodable {
    var center: Coordinate
}

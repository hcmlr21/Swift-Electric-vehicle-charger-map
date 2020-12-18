import Foundation
import SWXMLHash

struct ChargerStationResult: Codable {
    var chargerStation: ChargerStationModel
}

struct ChargerStationModel: Codable {
    var statId: String
    var statName: String
    var address: String
    var availableChargerCount: Int
    var lat: Double //위도
    var lng: Double//경도
    var useTime: String?
    var busiId: String?
    var busiName: String?
    var busiCall: String?
    var chargers: [ChargerModel]?
}

struct ChargerModel: Codable {
    var chargerId: String?
    var chargerType: String?
    var status: String?
    var statusUpdate: String?
    var powerType: String?
}

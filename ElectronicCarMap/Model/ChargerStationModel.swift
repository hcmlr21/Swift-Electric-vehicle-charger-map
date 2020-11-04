/*
 <statNm>종묘 공영주차장</statNm>
 <statId>ME000001</statId>
 <chgerId>01</chgerId>
 <chgerType>03</chgerType>
 <addr>서울특별시 종로구 종로 157, 지하주차장 4층 하층 T구역</addr>
 <lat>37.571076</lat>
 <lng>126.995880</lng>
 <useTime>24시간 이용가능</useTime>
 <busiId>ME</busiId>
 <busiNm>환경부</busiNm>
 <busiCall>1661-9408</busiCall>
 <stat>2</stat>
 <statUpdDt>20200410201106</statUpdDt>
 <powerType>급속(50kW)</powerType>
 */
import Foundation
import SWXMLHash

//    var statName: String
//    var statId: String
//    var lat: String //위도
//    var lng: String //경도
//    var useTime: String
//    var address: String
//    var busiId: String
//    var busiName: String
//    var busiCall: String

//    init() {
//        statName = ""
//        statId = ""
//        chargerId = ""
//        chargerType = ""
//        address = ""
//        lat = ""
//        lng = ""
//        useTime = ""
//        busiId = ""
//        busiName = ""
//        busiCall = ""
//        status = ""
//        statusUpdate = ""
//        powerType = ""
//    }

struct ChargerStationResult: Codable {
//    var success: Bool
    var chargerStation: ChargerStationModel
}

struct ChargerStationModel: Codable {
    var statId: String
    var statName: String
    var address: String
    var lat: String? //위도
    var lng: String?//경도
    var useTime: String?
    var busiId: String?
    var busiName: String?
    var busiCall: String?
    var chargers: [ChargerModel]?
}

struct ChargerModel: Codable {
    var chargerId: Int?
    var chargerType: String?
    var status: String?
    var statusUpdate: String?
    var powerType: String?
}

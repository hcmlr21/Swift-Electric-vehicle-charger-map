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


//struct ChargerInfo2: XMLIndexerDeserializable {
//    let addr: String
//    let chargeTp: Int
//    let cpId: Int
//    let cpNm: String
//    let cpStat: Int
//    let cpTp: Int
//    let csId: Int
//    let csNm: String
//    let lat: Double
//    let longi: Double
//    let statUpdateDatetime: String
//
//    static func deserialize(_ element: XMLIndexer) throws -> ChargerInfo2 {
//        return try ChargerInfo2(addr: element["addr"].value(), chargeTp: element["chargeTp"].value(), cpId: element["cpId"].value(), cpNm: element["cpNm"].value(), cpStat: element["cpStat"].value(), cpTp: element["cpTp"].value(), csId: element["csId"].value(), csNm: element["csNm"].value(), lat: element["lat"].value(), longi: element["longi"].value(), statUpdateDatetime: element["statUpdateDatetime"].value())
//    }
//}

//struct <#name#> {
//    <#fields#>
//}


struct ChargerStation: Codable {
    var address: String
    var statName: String
    var statId: String
    var lat: String //위도
    var lng: String //경도
    var useTime: String
    var busiId: String
    var busiName: String
    var busiCall: String
    var chargers: [Charger]
    
    struct Charger: Codable {
        var chargerId: String
        var chargerType: String
        var status: String
        var statusUpdate: String
        var powerType: String
    }
}

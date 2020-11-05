//
//  RoadAddressModel.swift
//  ElectronicCarMap
//
//  Created by Jkookoo on 2020/11/04.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import Foundation

struct AddrResponse: Codable {
    var results: Results?
}

struct Results: Codable {
//    var common: Common?
    var juso: [Juso]?
}

//struct Common: Codable {
//    var errorMessage: String?
//    var countPerPage: String?
//    var totalCount: String?
//    var errorCode: String?
//    var currentPage: String?
//}

struct Juso: Codable {
//    var detBdNmList: String?
//    var engAddr: String?
//    var rn: String?
//    var emdNm: String?
//    var zipNo: String?
//    var roadAddrPart2: String?
//    var emdNo: String?
//    var sggNm: String?
//    var jibunAddr: String?
//    var siNm: String?
    var roadAddrPart1: String?
    var bdNm: String?
//    var admCd: String?
//    var udrtYn: String?
//    var lnbrMnnm: String?
//    var roadAddr: String?
//    var lnbrSlno: String?
//    var buldMnnm: String?
//    var bdKdcd: String?
//    var liNm: String?
//    var rnMgtSn: String?
//    var mtYn: String?
//    var bdMgtSn: String?
//    var buldSlno: String?
}


struct CoordResponse: Codable {
    var addresses: [Address]
}

struct Address: Codable {
    var x: String?
    var y: String?
}

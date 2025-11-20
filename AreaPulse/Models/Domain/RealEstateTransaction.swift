//
//  RealEstateTransaction.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 부동산 실거래가 모델 (T_REAL_ESTATE_TRANSACTION 테이블 대응)
struct RealEstateTransaction: Identifiable, Codable, Hashable {
    let id: Int
    let buildingId: Int
    let transactionDate: Date
    let price: Int64
    let areaSqm: Double
    let floor: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "tx_id"
        case buildingId = "building_id"
        case transactionDate = "transaction_date"
        case price
        case areaSqm = "area_sqm"
        case floor
    }
    
    /// 거래 금액을 억/만원 형식으로 변환
    var formattedPrice: String {
        let billion = price / 10000
        let million = price % 10000
        
        if billion > 0 && million > 0 {
            return "\(billion)억 \(million)만원"
        } else if billion > 0 {
            return "\(billion)억원"
        } else {
            return "\(million)만원"
        }
    }
}

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
    
    // Custom decoder to handle various date formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        buildingId = try container.decode(Int.self, forKey: .buildingId)
        price = try container.decode(Int64.self, forKey: .price)
        areaSqm = try container.decode(Double.self, forKey: .areaSqm)
        floor = try container.decode(Int.self, forKey: .floor)
        
        // Try to decode date from various formats
        if let dateString = try? container.decode(String.self, forKey: .transactionDate) {
            let formatters = [
                // ISO8601 with time
                { () -> DateFormatter in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }(),
                // ISO8601 with milliseconds
                { () -> DateFormatter in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    return formatter
                }(),
                // Simple date format
                { () -> DateFormatter in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    return formatter
                }(),
                // Date with time and timezone
                { () -> DateFormatter in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    return formatter
                }()
            ]
            
            var parsedDate: Date?
            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    parsedDate = date
                    break
                }
            }
            
            guard let date = parsedDate else {
                throw DecodingError.dataCorruptedError(
                    forKey: .transactionDate,
                    in: container,
                    debugDescription: "Date string does not match expected formats. Received: \(dateString)"
                )
            }
            
            transactionDate = date
        } else if let timestamp = try? container.decode(Double.self, forKey: .transactionDate) {
            // Handle Unix timestamp (seconds since 1970)
            transactionDate = Date(timeIntervalSince1970: timestamp)
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .transactionDate,
                in: container,
                debugDescription: "Could not decode transaction_date as String or Double"
            )
        }
    }
    
    // Manual initializer for creating instances in code
    init(id: Int, buildingId: Int, transactionDate: Date, price: Int64, areaSqm: Double, floor: Int) {
        self.id = id
        self.buildingId = buildingId
        self.transactionDate = transactionDate
        self.price = price
        self.areaSqm = areaSqm
        self.floor = floor
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

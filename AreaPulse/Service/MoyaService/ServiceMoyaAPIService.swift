//
//  MoyaAPIService.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation
import Moya

/// Moya 기반 API 서비스
/// AreaPulseAPI를 사용하여 실제 네트워크 요청을 수행합니다.
final class MoyaAPIService: @unchecked Sendable {
    
    // MARK: - Properties
    
    static let shared = MoyaAPIService()
    
    private let provider: MoyaProvider<AreaPulseAPI>
    
    /// 토큰 갱신 중인지 여부 (중복 갱신 방지)
    private var isRefreshing = false
    
    /// 토큰 갱신 대기 중인 요청들
    private var pendingRequests: [(AreaPulseAPI, CheckedContinuation<Data, Error>)] = []
    
    /// 동기화용 락
    private let lock = NSLock()
    
    // MARK: - Mock 설정
    
    /// Mock 데이터 사용 여부
    /// true로 설정하면 실제 API 대신 sampleData를 반환합니다.
    /// API 구현 후 false로 변경하면 됩니다.
    static var useMockData: Bool = false // ⬅️ 여기만 false로 바꾸면 실제 API 사용!
    
    // MARK: - Initialization
    
    init(provider: MoyaProvider<AreaPulseAPI>? = nil) {
        if let provider = provider {
            self.provider = provider
        } else {
            // Mock 모드면 stubbing을 활성화
            if Self.useMockData {
                self.provider = MoyaProvider<AreaPulseAPI>(
                    stubClosure: { _ in .immediate }, // Mock 데이터를 즉시 반환
                    plugins: [
                        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
                    ]
                )
            } else {
                // 실제 API 모드
                self.provider = MoyaProvider<AreaPulseAPI>(
                    plugins: [
                        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
                    ]
                )
            }
        }
    }
    
    // MARK: - Private Helper
    
    /// API 요청을 수행하고 응답을 디코딩합니다.
    private func request<T: Decodable>(_ target: AreaPulseAPI) async throws -> T {
        let data = try await requestData(target)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // ISO8601 with timezone (Z or +00:00)
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }
            
            // ISO8601 without fractional seconds
            iso8601Formatter.formatOptions = [.withInternetDateTime]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }
            
            // Without timezone (서버에서 오는 형식: "2025-12-01T13:32:34")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            // Date only
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }
        return try decoder.decode(T.self, from: data)
    }
    
    /// API 요청을 수행하고 Data를 반환합니다. (401 처리 포함)
    private func requestData(_ target: AreaPulseAPI) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { [weak self] result in
                guard let self = self else {
                    continuation.resume(throwing: MoyaError.requestMapping("Service deallocated"))
                    return
                }
                
                switch result {
                case .success(let response):
                    // 401 Unauthorized - 토큰 만료
                    if response.statusCode == 401 {
                        self.handle401Error(target: target, continuation: continuation)
                        return
                    }
                    
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        continuation.resume(returning: filteredResponse.data)
                    } catch let moyaError as MoyaError {
                        if let response = moyaError.response {
                            print("❌ API Error - Status: \(response.statusCode)")
                            if let jsonString = String(data: response.data, encoding: .utf8) {
                                print("❌ Response Body: \(jsonString)")
                            }
                        }
                        continuation.resume(throwing: moyaError)
                    } catch {
                        print("❌ Unknown Error: \(error)")
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    // Moya validationType이 .successCodes면 401도 failure로 옴
                    if let response = error.response, response.statusCode == 401 {
                        self.handle401Error(target: target, continuation: continuation)
                        return
                    }
                    
                    print("❌ Network Error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// 401 에러 처리 - 토큰 갱신 후 재요청
    private func handle401Error(
        target: AreaPulseAPI,
        continuation: CheckedContinuation<Data, Error>
    ) {
        // refreshToken 요청 자체가 401이면 로그아웃
        if case .refreshToken = target {
            print("❌ Refresh token expired, logging out")
            DispatchQueue.main.async {
                AuthManager.shared.logout()
            }
            continuation.resume(throwing: AuthError.refreshTokenExpired)
            return
        }
        
        lock.lock()
        
        // 대기열에 추가
        pendingRequests.append((target, continuation))
        
        // 이미 갱신 중이면 대기
        if isRefreshing {
            lock.unlock()
            return
        }
        
        isRefreshing = true
        lock.unlock()
        
        // 토큰 갱신 시도
        performTokenRefresh()
    }
    
    /// 토큰 갱신 수행
    private func performTokenRefresh() {
        guard let refreshToken = AuthManager.shared.refreshToken else {
            print("❌ No refresh token available")
            handleRefreshFailure()
            return
        }
        
        // 토큰 갱신 요청
        provider.request(.refreshToken(refreshToken: refreshToken)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(RefreshTokenResponseDTO.self, from: filteredResponse.data)
                    
                    // 새 토큰 저장
                    DispatchQueue.main.async {
                        AuthManager.shared.refreshTokens(tokens: tokenResponse)
                    }
                    
                    print("✅ Token refreshed successfully")
                    
                    // 대기 중인 요청들 재시도
                    self.retryPendingRequests()
                    
                } catch {
                    print("❌ Token refresh decode failed: \(error)")
                    self.handleRefreshFailure()
                }
                
            case .failure(let error):
                print("❌ Token refresh failed: \(error)")
                self.handleRefreshFailure()
            }
        }
    }
    
    /// 대기 중인 요청들 재시도
    private func retryPendingRequests() {
        lock.lock()
        let requests = pendingRequests
        pendingRequests.removeAll()
        isRefreshing = false
        lock.unlock()
        
        for (target, continuation) in requests {
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        continuation.resume(returning: filteredResponse.data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// 갱신 실패 시 처리
    private func handleRefreshFailure() {
        // 로그아웃 처리
        DispatchQueue.main.async {
            AuthManager.shared.logout()
        }
        
        lock.lock()
        let requests = pendingRequests
        pendingRequests.removeAll()
        isRefreshing = false
        lock.unlock()
        
        // 대기 중인 요청들에 에러 전달
        for (_, continuation) in requests {
            continuation.resume(throwing: AuthError.sessionExpired)
        }
    }
    
    // MARK: - API Methods
    
    // MARK: - Auth
    
    /// 회원가입
    func register(
        email: String,
        password: String,
        nickname: String
    ) async throws -> RegisterResponseDTO {
        return try await request(.register(
            email: email,
            password: password,
            nickname: nickname
        ))
    }
    
    /// 로그인 (OAuth2)
    func login(
        email: String,
        password: String
    ) async throws -> LoginResponseDTO {
        return try await request(.login(
            email: email,
            password: password
        ))
    }
    
    /// 토큰 갱신
    func refreshToken(refreshToken: String) async throws -> RefreshTokenResponseDTO {
        return try await request(.refreshToken(refreshToken: refreshToken))
    }
    
    /// 로그아웃
    func logout() async throws -> LogoutResponseDTO {
        return try await request(.logout)
    }
    
    // MARK: - Search
    
    /// 핀포인트 검색
    func searchPoint(
        latitude: Double,
        longitude: Double,
        radiusMeters: Int
    ) async throws -> PointSearchResponseDTO {
        return try await request(.pointSearch(
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters
        ))
    }
    
    // MARK: - Building
    
    /// 건물 상세 정보 조회
    func getBuildingDetail(buildingId: Int) async throws -> BuildingDetailResponseDTO {
        return try await request(.buildingDetail(buildingId: buildingId))
    }
    
    /// 건물 리뷰 목록 조회
    func getBuildingReviews(buildingId: Int) async throws -> BuildingReviewsResponseDTO {
        return try await request(.buildingReviews(buildingId: buildingId))
    }
    
    // MARK: - Review
    
    /// 리뷰 작성
    func createReview(
        buildingId: Int,
        rating: Int,
        content: String
    ) async throws -> CreateReviewResponseDTO {
        return try await request(.createReview(
            buildingId: buildingId,
            rating: rating,
            content: content
        ))
    }
    
    // MARK: - Saved Building
    
    /// 찜한 건물 목록 조회
    func getSavedBuildings() async throws -> SavedBuildingsResponseDTO {
        return try await request(.savedBuildings)
    }
    
    /// 건물 찜하기
    func saveBuilding(buildingId: Int, memo: String?) async throws -> SaveBuildingResponseDTO {
        return try await request(.saveBuilding(buildingId: buildingId, memo: memo))
    }
    
    /// 찜한 건물 삭제
    func deleteSavedBuilding(saveId: Int) async throws -> DeleteSavedBuildingResponseDTO {
        return try await request(.deleteSavedBuilding(saveId: saveId))
    }
    
    // MARK: - Infrastructure
    
    /// 카테고리별 인프라 검색
    func getInfrastructureByCategory(
        category: InfraCategory,
        latitude: Double,
        longitude: Double,
        radiusMeters: Int
    ) async throws -> InfrastructureResponseDTO {
        return try await request(.infrastructureByCategory(
            category: category,
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters
        ))
    }
    
    // MARK: - Region
    
    /// 지역 통계 조회
    func getRegionStats(bjdCode: String) async throws -> RegionStatsResponseDTO {
        return try await request(.regionStats(bjdCode: bjdCode))
    }
    
    // MARK: - Environment
    
    /// 환경 데이터 조회
    func getEnvironmentData(
        latitude: Double,
        longitude: Double
    ) async throws -> EnvironmentDataResponseDTO {
        return try await request(.environmentData(
            latitude: latitude,
            longitude: longitude
        ))
    }
}

// MARK: - Auth Error

enum AuthError: Error, LocalizedError {
    case noRefreshToken
    case refreshTokenExpired
    case sessionExpired
    
    var errorDescription: String? {
        switch self {
        case .noRefreshToken:
            return "저장된 리프레시 토큰이 없습니다."
        case .refreshTokenExpired:
            return "리프레시 토큰이 만료되었습니다. 다시 로그인해주세요."
        case .sessionExpired:
            return "세션이 만료되었습니다. 다시 로그인해주세요."
        }
    }
}

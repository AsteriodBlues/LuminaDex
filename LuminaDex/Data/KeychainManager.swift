//
//  KeychainManager.swift
//  LuminaDex
//
//  Day 24: Secure storage for sensitive data
//

import Foundation
import KeychainAccess
import CryptoKit

class KeychainManager {
    static let shared = KeychainManager()
    
    private let keychain: Keychain
    private let serviceName = "com.luminadex.app"
    
    // Keys for stored values
    private enum Keys {
        static let userToken = "userToken"
        static let apiKey = "apiKey"
        static let syncToken = "syncToken"
        static let encryptionKey = "encryptionKey"
        static let biometricEnabled = "biometricEnabled"
        static let premiumStatus = "premiumStatus"
        static let cloudSyncEnabled = "cloudSyncEnabled"
        static let backupData = "backupData"
    }
    
    private init() {
        keychain = Keychain(service: serviceName)
            .synchronizable(true)
            .accessibility(.whenUnlocked)
    }
    
    // MARK: - User Authentication
    
    func saveUserToken(_ token: String) throws {
        try keychain.set(token, key: Keys.userToken)
    }
    
    func getUserToken() throws -> String? {
        return try keychain.getString(Keys.userToken)
    }
    
    func deleteUserToken() throws {
        try keychain.remove(Keys.userToken)
    }
    
    // MARK: - API Keys
    
    func saveAPIKey(_ key: String) throws {
        try keychain.set(key, key: Keys.apiKey)
    }
    
    func getAPIKey() throws -> String? {
        return try keychain.getString(Keys.apiKey)
    }
    
    // MARK: - Sync Token
    
    func saveSyncToken(_ token: String) throws {
        try keychain.set(token, key: Keys.syncToken)
    }
    
    func getSyncToken() throws -> String? {
        return try keychain.getString(Keys.syncToken)
    }
    
    // MARK: - Encryption
    
    func generateAndSaveEncryptionKey() throws -> Data {
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }
        try keychain.set(keyData, key: Keys.encryptionKey)
        return keyData
    }
    
    func getEncryptionKey() throws -> Data? {
        return try keychain.getData(Keys.encryptionKey)
    }
    
    func encryptData(_ data: Data) throws -> Data? {
        guard let keyData = try getEncryptionKey() else {
            _ = try generateAndSaveEncryptionKey()
            return try encryptData(data)
        }
        
        let key = SymmetricKey(data: keyData)
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined
    }
    
    func decryptData(_ encryptedData: Data) throws -> Data? {
        guard let keyData = try getEncryptionKey() else {
            return nil
        }
        
        let key = SymmetricKey(data: keyData)
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    // MARK: - Biometric Settings
    
    func setBiometricEnabled(_ enabled: Bool) throws {
        try keychain.set(enabled ? "true" : "false", key: Keys.biometricEnabled)
    }
    
    func isBiometricEnabled() throws -> Bool {
        guard let value = try keychain.getString(Keys.biometricEnabled) else {
            return false
        }
        return value == "true"
    }
    
    // MARK: - Premium Status
    
    func savePremiumStatus(_ status: PremiumStatus) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(status)
        try keychain.set(data, key: Keys.premiumStatus)
    }
    
    func getPremiumStatus() throws -> PremiumStatus? {
        guard let data = try keychain.getData(Keys.premiumStatus) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(PremiumStatus.self, from: data)
    }
    
    // MARK: - Cloud Sync
    
    func setCloudSyncEnabled(_ enabled: Bool) throws {
        try keychain.set(enabled ? "true" : "false", key: Keys.cloudSyncEnabled)
    }
    
    func isCloudSyncEnabled() throws -> Bool {
        guard let value = try keychain.getString(Keys.cloudSyncEnabled) else {
            return false
        }
        return value == "true"
    }
    
    // MARK: - Backup
    
    func saveBackupData(_ data: Data) throws {
        guard let encryptedData = try encryptData(data) else {
            throw KeychainError.encryptionFailed
        }
        try keychain.set(encryptedData, key: Keys.backupData)
    }
    
    func getBackupData() throws -> Data? {
        guard let encryptedData = try keychain.getData(Keys.backupData) else {
            return nil
        }
        return try decryptData(encryptedData)
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() throws {
        try keychain.removeAll()
    }
}

// MARK: - Supporting Types

struct PremiumStatus: Codable {
    let isPremium: Bool
    let expirationDate: Date?
    let tier: PremiumTier
    
    enum PremiumTier: String, Codable {
        case free = "Free"
        case basic = "Basic"
        case pro = "Pro"
        case ultra = "Ultra"
    }
}

enum KeychainError: LocalizedError {
    case encryptionFailed
    case decryptionFailed
    case dataNotFound
    
    var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .dataNotFound:
            return "Requested data not found in keychain"
        }
    }
}
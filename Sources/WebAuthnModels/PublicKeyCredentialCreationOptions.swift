//===----------------------------------------------------------------------===//
//
// This source file is part of webauthn-swift-models and includes modified code from
// the WebAuthn Swift open source project.
//
// Original WebAuthn Swift project:
// - Copyright (c) 2022 the WebAuthn Swift project authors
// - Licensed under Apache License v2.0
// - See LICENSE.txt in the webauthn-swift repository for license information
// - See CONTRIBUTORS.txt in the webauthn-swift repository for the list of project authors
//
// Modifications made by Robert Nash for webauthn-swift-models.
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation
import Crypto
import Base64Swift

/// The `PublicKeyCredentialCreationOptions` gets passed to the WebAuthn API (`navigator.credentials.create()`)
///
/// Generally this should not be created manually. Instead use `RelyingParty.beginRegistration()`. When encoding using
/// `Encodable` byte arrays are base64url encoded.
public struct PublicKeyCredentialCreationOptions: Codable {
    /// A byte array randomly generated by the Relying Party. Should be at least 16 bytes long to ensure sufficient
    /// entropy.
    ///
    /// The Relying Party should store the challenge temporarily until the registration flow is complete. When
    /// encoding using `Encodable`, the challenge is base64url encoded.
    public let challenge: [UInt8]

    /// Contains names and an identifier for the user account performing the registration
    public let user: PublicKeyCredentialUserEntity

    /// Contains a name and an identifier for the Relying Party responsible for the request
    public let relyingParty: PublicKeyCredentialRpEntity

    /// A list of key types and signature algorithms the Relying Party supports. Ordered from most preferred to least
    /// preferred.
    public let publicKeyCredentialParameters: [PublicKeyCredentialParameters]

    /// A time, in milliseconds, that the caller is willing to wait for the call to complete. This is treated as a
    /// hint, and may be overridden by the client.
    public let timeoutInMilliseconds: UInt32?

    /// Sets the Relying Party's preference for attestation conveyance. At the time of writing only `none` is
    /// supported.
    public let attestation: AttestationConveyancePreference
    
    public init(
        challenge: [UInt8],
        user: PublicKeyCredentialUserEntity,
        relyingParty: PublicKeyCredentialRpEntity,
        publicKeyCredentialParameters: [PublicKeyCredentialParameters],
        timeoutInMilliseconds: UInt32?,
        attestation: AttestationConveyancePreference
    ) {
        self.challenge = challenge
        self.user = user
        self.relyingParty = relyingParty
        self.publicKeyCredentialParameters = publicKeyCredentialParameters
        self.timeoutInMilliseconds = timeoutInMilliseconds
        self.attestation = attestation
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(URLEncodedBase64(bytes: challenge), forKey: .challenge)
        try container.encode(user, forKey: .user)
        try container.encode(relyingParty, forKey: .relyingParty)
        try container.encode(publicKeyCredentialParameters, forKey: .publicKeyCredentialParameters)
        try container.encodeIfPresent(timeoutInMilliseconds, forKey: .timeoutInMilliseconds)
        try container.encode(attestation, forKey: .attestation)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let challenge = try container.decodeBytesFromURLEncodedBase64(forKey: .challenge)
        let user = try container.decode(PublicKeyCredentialUserEntity.self, forKey: .user)
        let rp = try container.decode(PublicKeyCredentialRpEntity.self, forKey: .relyingParty)
        let publicKeyCredentialParameters = try container.decode([PublicKeyCredentialParameters].self, forKey: .publicKeyCredentialParameters)
        let timeoutInMilliseconds = try container.decodeIfPresent(UInt32.self, forKey: .timeoutInMilliseconds)
        let attestation = try container.decode(AttestationConveyancePreference.self, forKey: .attestation)
        
        self.init(
            challenge: challenge,
            user: user,
            relyingParty: rp,
            publicKeyCredentialParameters: publicKeyCredentialParameters,
            timeoutInMilliseconds: timeoutInMilliseconds,
            attestation: attestation
        )
    }

    private enum CodingKeys: String, CodingKey {
        case challenge
        case user
        case relyingParty = "rp"
        case publicKeyCredentialParameters = "pubKeyCredParams"
        case timeoutInMilliseconds = "timeout"
        case attestation
    }
}

/// From §5.4.2 (https://www.w3.org/TR/webauthn/#sctn-rp-credential-params).
/// The PublicKeyCredentialRpEntity dictionary is used to supply additional Relying Party attributes when
/// creating a new credential.
public struct PublicKeyCredentialRpEntity: Codable {
    /// A unique identifier for the Relying Party entity.
    public let id: String

    /// A human-readable identifier for the Relying Party, intended only for display. For example, "ACME Corporation",
    /// "Wonderful Widgets, Inc." or "ОАО Примертех".
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

 /// From §5.4.3 (https://www.w3.org/TR/webauthn/#dictionary-user-credential-params)
 /// The PublicKeyCredentialUserEntity dictionary is used to supply additional user account attributes when
 /// creating a new credential.
 ///
 /// When encoding using `Encodable`, `id` is base64url encoded.
public struct PublicKeyCredentialUserEntity: Codable {
    /// Generated by the Relying Party, unique to the user account, and must not contain personally identifying
    /// information about the user.
    ///
    /// When encoding this is base64url encoded.
    public let id: [UInt8]

    /// A human-readable identifier for the user account, intended only for display. It helps the user to
    /// distinguish between user accounts with similar `displayName`s. For example, two different user accounts
    /// might both have the same `displayName`, "Alex P. Müller", but might have different `name` values "alexm",
    /// "alex.mueller@example.com" or "+14255551234".
    public let name: String

    /// A human-readable name for the user account, intended only for display. For example, "Alex P. Müller" or
    /// "田中 倫"
    public let displayName: String

    /// Creates a new ``PublicKeyCredentialUserEntity`` from id, name and displayName
    public init(id: [UInt8], name: String, displayName: String) {
        self.id = id
        self.name = name
        self.displayName = displayName
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(URLEncodedBase64(bytes: id), forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(displayName, forKey: .displayName)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decodeBytesFromURLEncodedBase64(forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let displayName = try container.decode(String.self, forKey: .displayName)
        self.init(id: id, name: name, displayName: displayName)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case displayName
    }
}

/// Options to specify the Relying Party's preference regarding attestation conveyance during credential generation.
///
/// Currently only supports `none`.
public enum AttestationConveyancePreference: String, Codable {
    /// Indicates the Relying Party is not interested in authenticator attestation.
    case none
    // case indirect
    // case direct
    // case enterprise
}

// MARK: - Credential parameters
/// From §5.3 (https://w3c.github.io/TR/webauthn/#dictionary-credential-params)
public struct PublicKeyCredentialParameters: Equatable, Codable {
    /// The type of credential to be created. At the time of writing always "public-key".
    public let type: String
    /// The cryptographic signature algorithm with which the newly generated credential will be used, and thus also
    /// the type of asymmetric key pair to be generated, e.g., RSA or Elliptic Curve.
    public let alg: COSEAlgorithmIdentifier

    /// Creates a new `PublicKeyCredentialParameters` instance.
    ///
    /// - Parameters:
    ///   - type: The type of credential to be created. At the time of writing always "public-key".
    ///   - alg: The cryptographic signature algorithm to be used with the newly generated credential.
    ///     For example RSA or Elliptic Curve.
    public init(type: String = "public-key", alg: COSEAlgorithmIdentifier) {
        self.type = type
        self.alg = alg
    }
}

/// COSEAlgorithmIdentifier From §5.10.5. A number identifying a cryptographic algorithm. The algorithm
/// identifiers SHOULD be values registered in the IANA COSE Algorithms registry
/// [https://www.w3.org/TR/webauthn/#biblio-iana-cose-algs-reg], for instance, -7 for "ES256" and -257 for "RS256".
public enum COSEAlgorithmIdentifier: Int, RawRepresentable, CaseIterable, Codable {
    /// AlgES256 ECDSA with SHA-256
    case algES256 = -7
    /// AlgES384 ECDSA with SHA-384
    case algES384 = -35
    /// AlgES512 ECDSA with SHA-512
    case algES512 = -36

    // We don't support RSA yet

    // /// AlgRS1 RSASSA-PKCS1-v1_5 with SHA-1
    // case algRS1 = -65535
    // /// AlgRS256 RSASSA-PKCS1-v1_5 with SHA-256
    // case algRS256 = -257
    // /// AlgRS384 RSASSA-PKCS1-v1_5 with SHA-384
    // case algRS384 = -258
    // /// AlgRS512 RSASSA-PKCS1-v1_5 with SHA-512
    // case algRS512 = -259
    // /// AlgPS256 RSASSA-PSS with SHA-256
    // case algPS256 = -37
    // /// AlgPS384 RSASSA-PSS with SHA-384
    // case algPS384 = -38
    // /// AlgPS512 RSASSA-PSS with SHA-512
    // case algPS512 = -39
    // // AlgEdDSA EdDSA
    // case algEdDSA = -8

    func hashAndCompare(data: Data, to compareHash: Data) -> Bool {
        switch self {
        case .algES256:
            return SHA256.hash(data: data) == compareHash
        case .algES384:
            return SHA384.hash(data: data) == compareHash
        case .algES512:
            return SHA512.hash(data: data) == compareHash
        }
    }
}

extension Array where Element == PublicKeyCredentialParameters {
    /// A list of `PublicKeyCredentialParameters` WebAuthn Swift currently supports.
    public static var supported: [Element] {
        COSEAlgorithmIdentifier.allCases.map {
            Element.init(type: "public-key", alg: $0)
        }
    }
}

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
import Base64Swift

public extension KeyedDecodingContainer {
    
    func decodeBytesFromURLEncodedBase64(forKey key: KeyedDecodingContainer.Key) throws -> [UInt8] {
        let this = try decode(URLEncodedBase64.self, forKey: key)
        return this.bytes
    }

    func decodeBytesFromURLEncodedBase64IfPresent(forKey key: KeyedDecodingContainer.Key) throws -> [UInt8]? {
        guard let this = try decodeIfPresent(URLEncodedBase64.self, forKey: key) else { return nil }
        return this.bytes
    }
}

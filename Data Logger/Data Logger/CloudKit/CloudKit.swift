//
//  CloudKit.swift
//  Data Logger
//
//  Created by Adam Kopec on 13/09/2022.
//

import CloudKit

func getAppleIDName() async throws -> String {
    let status = try await CKContainer.default().requestApplicationPermission(.userDiscoverability)
    print(status)
    let userRecord = try await CKContainer.default().userRecordID()
    let userIdentity = try await CKContainer.default().userIdentity(forUserRecordID: userRecord)
    print(userIdentity?.hasiCloudAccount as Any)
    print(userIdentity?.lookupInfo?.phoneNumber as Any)
    print(userIdentity?.lookupInfo?.emailAddress as Any)
    print((userIdentity?.nameComponents?.givenName)! + " " + (userIdentity?.nameComponents?.familyName)!)
    return ((userIdentity?.nameComponents?.givenName)! + " " + (userIdentity?.nameComponents?.familyName)!)
}

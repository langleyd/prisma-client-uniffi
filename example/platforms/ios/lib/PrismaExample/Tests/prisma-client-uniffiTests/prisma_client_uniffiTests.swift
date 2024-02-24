import XCTest
@testable import prisma_client_uniffi

final class prisma_client_uniffiTests: XCTestCase {
    func testExample() async throws {
//        print(try FileManager.default.currentDirectoryPath)
        let client = Client()
        client.dbReset()
        client.createAccount(id: "1", displayName: "Alice")
        client.createAccount(id: "2", displayName: "Bob")
        client.createAccount(id: "3", displayName: "Charlie")
    }
}

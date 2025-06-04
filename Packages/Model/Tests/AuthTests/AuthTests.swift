import ATProtoKit
import Auth
import Testing
import Foundation

struct AuthTests {

  @Test func testSessionLastRefreshedUpdatesOnLogout() async throws {
    let auth = Auth()
    let initialDate = Date()

    try await Task.sleep(nanoseconds: 1_000_000)

    try await auth.logout()

    #expect(auth.sessionLastRefreshed! > initialDate)
    #expect(auth.configuration == nil)
  }

  @Test func testLogoutClearsConfiguration() async throws {
    let auth = Auth()

    try await auth.logout()

    #expect(auth.configuration == nil)
  }

  @Test func testRefreshWithoutTokensReturnsEarly() async throws {
    let auth = Auth()
    let initialDate = Date()

    try await Task.sleep(nanoseconds: 1_000_000)

    await auth.refresh()

    #expect(auth.sessionLastRefreshed! > initialDate)
    #expect(auth.configuration == nil)
  }

  @Test func testSessionLastRefreshedUpdatesOnRefresh() async throws {
    let auth = Auth()
    let initialDate = Date()

    try await Task.sleep(nanoseconds: 1_000_000)

    await auth.refresh()

    #expect(auth.sessionLastRefreshed! > initialDate)
  }

  @Test func testAuthInstanceCreation() {
    let auth1 = Auth()
    let auth2 = Auth()

    #expect(auth1.configuration == nil)
    #expect(auth2.configuration == nil)
  }
}

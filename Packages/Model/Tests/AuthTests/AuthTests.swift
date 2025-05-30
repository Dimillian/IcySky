import Testing
import Auth
import ATProtoKit

struct AuthTests {
  @Test func testLoginLogoutFlow() {
    let auth = Auth()
    #expect(auth.configuration?.session == nil)
  }
}

import ATProtoKit
import Auth
import Testing

struct AuthTests {
  @Test func testLoginLogoutFlow() {
    let auth = Auth()
    #expect(auth.configuration?.session == nil)
  }
}

import Testing
import Auth

struct AuthTests {
  struct FakeAuthSession: AuthSession {
    let accessToken: String
    let refreshToken: String
  }
  
  @Test func testLoginLogoutFlow() {
    let auth = Auth(session: FakeAuthSession(accessToken: "test", refreshToken: "test_refesh"))
    #expect(auth.session != nil)
    auth.logout()
    #expect(auth.session == nil)
  }
}

import ATProtoKit
import Auth
import Testing
import Foundation

struct AuthTests {

  @Test func testLogoutClearsConfigurationAndEmitsNil() async throws {
    let auth = Auth()
    
    // Start collecting updates before triggering logout
    let task = Task {
      var result: ATProtocolConfiguration?
      for await config in auth.configurationUpdates {
        result = config
        break
      }
      return result
    }
    
    try await auth.logout()
    
    let emittedConfig = await task.value
    #expect(emittedConfig == nil)
    #expect(auth.configuration == nil)
  }

  @Test func testRefreshEmitsNilOnFailure() async throws {
    let auth = Auth()
    
    // Start collecting updates before triggering refresh
    let task = Task {
      var result: ATProtocolConfiguration?
      for await config in auth.configurationUpdates {
        result = config
        break
      }
      return result
    }
    
    await auth.refresh()
    
    let emittedConfig = await task.value
    #expect(emittedConfig == nil)
    #expect(auth.configuration == nil)
  }

  @Test func testAuthInstanceCreation() {
    let auth1 = Auth()
    let auth2 = Auth()

    #expect(auth1.configuration == nil)
    #expect(auth2.configuration == nil)
  }
  
  @Test func testConfigurationUpdatesStream() async throws {
    let auth = Auth()
    var updates: [ATProtocolConfiguration?] = []
    
    let task = Task {
      for await config in auth.configurationUpdates {
        updates.append(config)
        if updates.count >= 2 { break }
      }
    }
    
    // Simulate logout (emits nil)
    try await auth.logout()
    
    // Simulate refresh failure (emits nil)
    await auth.refresh()
    
    try await Task.sleep(nanoseconds: 100_000_000) // 100ms
    task.cancel()
    
    #expect(updates.count == 2)
    #expect(updates.allSatisfy { $0 == nil })
  }
}
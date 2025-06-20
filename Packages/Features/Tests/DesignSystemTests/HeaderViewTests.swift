import DesignSystem
import SwiftUI
import Testing
import ViewInspector

struct HeaderViewTests {
  @Test func testHeaderViewTitle() throws {
    let title = "TestTitle"
    let headerView = HeaderView(title: title, showBack: false)
    #expect(try headerView.inspect().find(text: title).string() == title)
  }

  @Test func testHeaderViewBackButton() throws {
    let title = "TestTitle"
    let headerView = HeaderView(title: title, showBack: true)
    #expect(try headerView.inspect().find(viewWithId: "back").image().font() == .title)
  }
}

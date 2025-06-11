import DesignSystem
import Network
import SwiftUI

struct ComposerToolbarView: ToolbarContent {
  @Binding var text: String
  @Binding var sendState: ComposerSendState

  var body: some ToolbarContent {
    ToolbarItem(placement: .keyboard) {
      Button {
      } label: {
        Image(systemName: "photo")
          .foregroundStyle(.indigoPurple)
      }

    }
    
    ToolbarItem(placement: .keyboard) {
      Button {
      } label: {
        Image(systemName: "film")
          .foregroundStyle(.indigoPurple)
      }
    }

    
    ToolbarItem(placement: .keyboard) {
      Button {
      } label: {
        Image(systemName: "camera")
          .foregroundStyle(.indigoPurple)
      }
    }
    
    ToolbarSpacer(placement: .keyboard)
       
    ToolbarItem(placement: .keyboard) {
      Button {
      } label: {
        Image(systemName: "at")
          .foregroundStyle(.indigoPurple)
      }
    }
    
    ToolbarItem(placement: .keyboard) {
      Button {
      } label: {
        Image(systemName: "tag")
          .foregroundStyle(.indigoPurple)
      }
    }

    ToolbarItem(placement: .keyboard) {
      Text("\(300 - text.count)")
        .foregroundStyle(text.count > 250 ? .redPurple : .indigoPurple)
        .font(.subheadline)
        .contentTransition(.numericText(value: Double(text.count)))
        .monospacedDigit()
        .lineLimit(1)
        .animation(.smooth, value: text.count)
    }
  }
}

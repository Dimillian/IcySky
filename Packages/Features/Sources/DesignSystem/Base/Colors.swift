import SwiftUI

extension Color {
  public static var shadowPrimary: Color {
    Color("shadowPrimary", bundle: .module)
  }

  public static var shadowSecondary: Color {
    Color("shadowSecondary", bundle: .module)
  }

  public static var blueskyBackground: Color {
    Color(UIColor(red: 2 / 255, green: 113 / 255, blue: 1, alpha: 1))
  }
}

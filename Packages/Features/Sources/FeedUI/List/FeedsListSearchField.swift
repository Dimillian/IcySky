import SwiftUI

struct FeedsListSearchField: View {

  @Binding var searchText: String
  @Binding var isInSearch: Bool
  var isSearchFocused: FocusState<Bool>.Binding

  var body: some View {
    HStack {
      HStack {
        Image(systemName: "magnifyingglass")
        TextField("Search", text: $searchText)
          .focused(isSearchFocused)
          .allowsHitTesting(isInSearch)
      }
      .frame(maxWidth: isInSearch ? .infinity : 100)
      .padding()
      .pillStyle()
      if isInSearch {
        Button {
          isInSearch.toggle()
          isSearchFocused.wrappedValue = false
          searchText = ""
        } label: {
          Image(systemName: "xmark")
            .frame(width: 50, height: 50)
        }
        .buttonStyle(.circle)
      }
    }
  }
}
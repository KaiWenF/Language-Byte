import SwiftUI

struct CategorySelectionView: View {
    @EnvironmentObject var viewModel: WordViewModel
    @Environment(\.dismiss) var dismiss

    // Change from stored property to computed property
    var categories: [String] {
        return viewModel.availableCategories
    }

    var body: some View {
        List {
            Section(header: Text("Select a Category")) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        if category == "All" {
                            viewModel.selectCategory(nil)
                        } else {
                            viewModel.selectCategory(category)
                        }
                        dismiss()
                    }) {
                        HStack {
                            Text(category)
                            Spacer()
                            if viewModel.selectedCategory?.lowercased() == category.lowercased() || (viewModel.selectedCategory == nil && category == "All") {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Categories")
    }
} 
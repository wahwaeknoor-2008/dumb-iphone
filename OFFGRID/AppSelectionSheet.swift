import FamilyControls
import SwiftUI

struct AppSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: FamilyActivitySelection

    private let accent = Color(red: 0.77, green: 0.95, blue: 0.45)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(accent)
                    Text("This picker shows apps and websites available to the device. The iOS Simulator may show categories but no individual apps. Use your physical iPhone to select your installed essentials.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial)

                FamilyActivityPicker(selection: $selection)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("What stays available")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

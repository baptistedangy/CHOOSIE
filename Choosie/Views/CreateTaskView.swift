import SwiftUI

struct CreateTaskView: View {
    @Binding var path: NavigationPath
    @StateObject private var viewModel = CreateTaskViewModel()
    @State private var navigateToShare = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Créer une tâche")
                .font(.title)
                .fontWeight(.semibold)
            TextField("Nom de la tâche", text: $viewModel.taskName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
#if os(iOS)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
#endif
            #if os(iOS)
            TextField("Montant total (€)", text: $viewModel.totalAmountString)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            #else
            TextField("Montant total (€)", text: $viewModel.totalAmountString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            #endif
            Stepper(value: $viewModel.participantCount, in: 2...20) {
                Text("Nombre de participants : \(viewModel.participantCount)")
            }
            Button(action: {
                if viewModel.createTask() {
                    navigateToShare = true
                }
            }) {
                Text("Créer")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canCreate ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!viewModel.canCreate)
            NavigationLink(destination: ShareView(code: viewModel.generatedCode ?? "", path: $path), isActive: $navigateToShare) {
                EmptyView()
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @State var path = NavigationPath()
    return CreateTaskView(path: $path)
} 
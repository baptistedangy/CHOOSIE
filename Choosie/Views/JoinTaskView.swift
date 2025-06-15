import SwiftUI

struct JoinTaskView: View {
    @Binding var path: NavigationPath
    @StateObject private var viewModel = JoinTaskViewModel()
    @State private var navigateToParticipation = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Rejoindre une tâche")
                .font(.title)
                .fontWeight(.semibold)
            TextField("Code de la tâche", text: $viewModel.code)
                .textFieldStyle(RoundedBorderTextFieldStyle())
#if os(iOS)
                .textInputAutocapitalization(.characters)
                .disableAutocorrection(true)
                .multilineTextAlignment(.center)
#endif
                .frame(maxWidth: 200)
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            Button(action: {
                if viewModel.joinTask() {
                    navigateToParticipation = true
                }
            }) {
                Text("Rejoindre")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canJoin ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!viewModel.canJoin)
            NavigationLink(
                destination: Group {
                    if let task = viewModel.foundTask {
                        ParticipationView(task: task, path: $path)
                    } else {
                        EmptyView()
                    }
                },
                isActive: $navigateToParticipation
            ) {
                EmptyView()
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @State var path = NavigationPath()
    return JoinTaskView(path: $path)
} 
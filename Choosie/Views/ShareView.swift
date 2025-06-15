import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ShareView: View {
    let code: String
    @Binding var path: NavigationPath
    @State private var navigateToParticipation = false
    @State private var task: TaskModel? = nil
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Code d'invitation")
                .font(.title2)
            Text(code)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .padding()
                #if canImport(UIKit)
                .background(Color(UIColor.systemGray6))
                #else
                .background(Color.gray.opacity(0.2))
                #endif
                .cornerRadius(10)
            Spacer()
            Button(action: {
                if let foundTask = TaskService.shared.getTask(by: code) {
                    self.task = foundTask
                    self.navigateToParticipation = true
                }
            }) {
                Text("Continuer")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            NavigationLink(
                destination: Group {
                    if let task = task {
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
    return ShareView(code: "X4E2LQ", path: $path)
} 
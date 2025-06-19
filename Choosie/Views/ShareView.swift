import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

struct ShareView: View {
    var mission: MissionModel?
    let code: String
    @Binding var path: NavigationPath
    @State private var showShareSheet = false
    @State private var showCopyAlert = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Code d'invitation")
                .font(.title2)
            HStack {
                Spacer()
                Text(code)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange, lineWidth: 2)
                    )
                Spacer()
            }
            
            HStack(spacing: 16) {
                Button(action: {
                    #if os(iOS)
                    UIPasteboard.general.string = code
                    #else
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(code, forType: .string)
                    #endif
                    showCopyAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showCopyAlert = false
                    }
                }) {
                    Label("Copier", systemImage: "doc.on.doc")
                        .padding(8)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(8)
                }
                
                #if os(iOS)
                Button(action: {
                    showShareSheet = true
                }) {
                    Label("Partager", systemImage: "square.and.arrow.up")
                        .padding(8)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(8)
                }
                #endif
            }
            #if os(iOS)
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: ["Rejoins mon Jackpot avec le code : \(code)"])
            }
            #endif
            
            if showCopyAlert {
                Text("Code copié !")
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
            
            Button(action: {
                if let mission = mission {
                    path.append(mission)
                }
            }) {
                Text("Continuer")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
    }
}

#if canImport(UIKit)
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
import AppKit
struct ShareSheet: NSViewControllerRepresentable {
    var activityItems: [Any]
    func makeNSViewController(context: Context) -> NSViewController {
        let controller = NSViewController()
        let picker = NSSharingServicePicker(items: activityItems)
        DispatchQueue.main.async {
            if let view = controller.view.window?.contentView {
                picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
            }
        }
        return controller
    }
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
}
#endif

#if os(macOS)
import AppKit
struct MacShareButton: View {
    let message: String
    var body: some View {
        Button(action: {
            let picker = NSSharingServicePicker(items: [message])
            if let window = NSApplication.shared.keyWindow,
               let contentView = window.contentView {
                picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
            }
        }) {
            Label("Partager", systemImage: "square.and.arrow.up")
                .padding(8)
                .background(Color.green.opacity(0.15))
                .cornerRadius(8)
        }
    }
}
#endif

#Preview("Partager") {
    NavigationStack {
        ShareView(
            mission: nil,
            code: "X4E2LQ",
            path: .constant(NavigationPath())
        )
    }
} 
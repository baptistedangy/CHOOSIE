import SwiftUI
import AVFoundation

struct SlotMachineView: View {
    let participants: [String]
    let amount: Decimal
    let onResult: (Int) -> Void
    @State private var isSpinning = false
    @State private var canSpin = true
    @State private var showResult = false
    @State private var selectedIndex: Int? = nil
    @State private var winnerIndex: Int = 0
    @State private var showContinue = false
    @State private var offset: CGFloat = 0
    @State private var animationStarted = false
    @State private var startIdx: Int = 0
    @State private var displayList: [String] = []

    let repeatCount = 30
    let rowHeight: CGFloat = 50
    let visibleRows = 3
    let animationDuration: Double = 3.5
    let soundID: SystemSoundID = 1108 // Son système "jackpot"

    var totalRows: Int { displayList.count }
    var centerRow: Int { totalRows / 2 }

    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 180, height: rowHeight * CGFloat(visibleRows))
                    .shadow(radius: 8)
                VStack(spacing: 0) {
                    ForEach(0..<totalRows, id: \ .self) { idx in
                        Text(displayList[idx])
                            .font(.title2)
                            .fontWeight(centerRow == idx ? .bold : .regular)
                            .foregroundColor(centerRow == idx ? .purple : .primary)
                            .frame(height: rowHeight)
                            .opacity(centerRow == idx ? 1 : 0.4)
                    }
                }
                .offset(y: offset)
                .frame(height: rowHeight * CGFloat(visibleRows))
                .clipped()
            }
            if showResult, let idx = selectedIndex {
                VStack(spacing: 20) {
                    Text("🎉 \(participants[idx]) a été désigné pour accomplir la mission et a reçu \(amountFormatter(amount)) € !")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.purple)
                        .padding(.top, 12)
                    Button("Créer une nouvelle mission") {
                        showContinue = true
                    }
                    .font(.title3)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .onAppear {
            if !animationStarted {
                animationStarted = true
                // Générer la liste étendue et choisir le gagnant
                let extended = Array(repeating: participants, count: repeatCount).flatMap { $0 }
                displayList = extended
                let randomStart = Int.random(in: 0..<(extended.count - participants.count * 2))
                startIdx = randomStart
                offset = -CGFloat(randomStart - centerRow) * rowHeight
                startSpin(from: randomStart)
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showContinue) {
            EmptyView()
        }
        #else
        .sheet(isPresented: $showContinue) {
            EmptyView()
        }
        #endif
    }

    private func startSpin(from: Int) {
        guard canSpin else { return }
        canSpin = false
        isSpinning = true
        // Choisir le gagnant aléatoirement
        let loserIdx = Int.random(in: 0..<participants.count)
        winnerIndex = loserIdx
        // Calculer l'index final dans la liste étendue pour que le gagnant soit centré
        let finalIdx = centerRow + loserIdx
        let totalDistance = CGFloat(finalIdx - from) * rowHeight
        // Animation : phase rapide puis ralentissement (easeOut)
        withAnimation(.timingCurve(0.1, 0.9, 0.2, 1, duration: animationDuration)) {
            offset = -CGFloat(finalIdx - centerRow) * rowHeight
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            isSpinning = false
            selectedIndex = winnerIndex
            showResult = true
            playJackpotEffect()
            onResult(winnerIndex)
        }
    }

    private func playJackpotEffect() {
        #if os(iOS)
        AudioServicesPlaySystemSound(soundID)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        #endif
    }

    private func amountFormatter(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(for: NSDecimalNumber(decimal: amount)) ?? "0.00"
    }
} 
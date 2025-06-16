import SwiftUI
import AVFoundation

struct SlotMachineView: View {
    let participants: [String]
    let onResult: (Int) -> Void
    @State private var isSpinning = false
    @State private var canSpin = true
    @State private var showResult = false
    @State private var selectedIndex: Int? = nil
    @State private var winnerIndex: Int = 0
    @State private var showContinue = false
    @State private var currentIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var animationPhase: Int = 0

    let repeatCount = 20
    let rowHeight: CGFloat = 60
    let fastPhaseTicks = 30
    let slowPhaseTicks = 30
    let soundID: SystemSoundID = 1108 // Son système "jackpot"

    var displayList: [String] {
        Array(repeating: participants, count: repeatCount).flatMap { $0 }
    }
    var totalRows: Int { displayList.count }
    var centerRow: Int { totalRows / 2 }

    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 180, height: 120)
                    .shadow(radius: 8)
                VStack(spacing: 0) {
                    ForEach(0..<totalRows, id: \ .self) { idx in
                        Text(displayList[idx])
                            .font(.largeTitle)
                            .fontWeight(centeredIndex == idx ? .bold : .regular)
                            .foregroundColor(centeredIndex == idx ? .purple : .primary)
                            .frame(height: rowHeight)
                            .opacity(centeredIndex == idx ? 1 : 0.4)
                    }
                }
                .offset(y: CGFloat(centerRow - currentIndex) * rowHeight)
                .clipped()
            }
            if showResult, let idx = selectedIndex {
                VStack(spacing: 16) {
                    Text("🎉 C'est \(participants[idx]) qui doit accomplir la mission !")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                        .padding(.top, 24)
                    Button("Continuer") {
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
            if canSpin && !isSpinning && !showResult {
                startSpin()
            }
        }
        .onDisappear { timer?.invalidate() }
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

    private var centeredIndex: Int {
        centerRow
    }

    private func startSpin() {
        guard canSpin else { return }
        canSpin = false
        isSpinning = true
        // Choisir le perdant aléatoirement
        let loserIdx = Int.random(in: 0..<participants.count)
        winnerIndex = loserIdx
        // Calculer l'index final dans la liste étendue
        let finalIdx = centerRow + loserIdx
        // Phase 1 : défilement rapide
        var tick = 0
        var currentDelay = 0.03
        currentIndex = Int.random(in: 0..<totalRows)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: currentDelay, repeats: true) { t in
            tick += 1
            currentIndex = (currentIndex + 1) % totalRows
            if tick >= fastPhaseTicks {
                t.invalidate()
                // Phase 2 : ralentissement progressif
                slowSpin(current: currentIndex, to: finalIdx, step: 1, delay: 0.05)
            }
        }
    }

    private func slowSpin(current: Int, to: Int, step: Int, delay: Double) {
        var idx = current
        var d = delay
        let totalSteps = slowPhaseTicks
        func next(stepNum: Int) {
            guard stepNum <= totalSteps else {
                // Phase 3 : arrêt précis
                finishSpin(finalIdx: to)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + d) {
                idx = (idx + 1) % totalRows
                currentIndex = idx
                d += 0.015 // ralentissement progressif
                next(stepNum: stepNum + 1)
            }
        }
        next(stepNum: 1)
    }

    private func finishSpin(finalIdx: Int) {
        // Animation finale pour s'arrêter pile sur le perdant
        let steps = (finalIdx - currentIndex + totalRows) % totalRows
        let baseDelay = 0.07
        func finalStep(i: Int) {
            guard i <= steps else {
                isSpinning = false
                selectedIndex = winnerIndex
                showResult = true
                playJackpotEffect()
                onResult(winnerIndex)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + baseDelay + Double(i) * 0.01) {
                currentIndex = (currentIndex + 1) % totalRows
                finalStep(i: i + 1)
            }
        }
        finalStep(i: 1)
    }

    private func playJackpotEffect() {
        #if os(iOS)
        AudioServicesPlaySystemSound(soundID)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        #endif
    }
} 
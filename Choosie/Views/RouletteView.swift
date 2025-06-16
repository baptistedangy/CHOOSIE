import SwiftUI

struct RouletteView: View {
    let participants: [String]
    let onResult: (Int) -> Void
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var selectedIndex: Int? = nil
    @State private var showResult = false
    @State private var canSpin = true
    @State private var winnerIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var totalSegments: Int = 0

    let wheelSize: CGFloat = 300
    let spinDuration: Double = 3.5
    let repeatCount = 10

    var extendedList: [String] {
        Array(repeating: participants, count: repeatCount).flatMap { $0 }
    }

    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                // Roue
                WheelShape(segmentCount: extendedList.count)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: wheelSize, height: wheelSize)
                ForEach(0..<extendedList.count, id: \ .self) { idx in
                    WheelSegment(
                        index: idx,
                        total: extendedList.count,
                        label: extendedList[idx],
                        isSelected: selectedIndex == idx && showResult
                    )
                    .frame(width: wheelSize, height: wheelSize)
                }
                // Flèche
                Triangle()
                    .fill(Color.red)
                    .frame(width: 30, height: 30)
                    .offset(y: -wheelSize/2 - 10)
                    .zIndex(1)
            }
            .rotationEffect(.degrees(rotation))
            .padding(.top, 40)
            if canSpin {
                Button(action: spin) {
                    Text("Lancer la roulette")
                        .font(.title2)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            if showResult, let idx = selectedIndex {
                Text("🎉 C'est \(extendedList[idx]) qui doit accomplir la mission !")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                    .padding(.top, 24)
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    private func spin() {
        guard canSpin else { return }
        canSpin = false
        isSpinning = true
        // Choisir le gagnant (dans la liste de base)
        let winner = Int.random(in: 0..<participants.count)
        winnerIndex = winner
        // Calculer l'index cible dans la liste étendue
        let finalIdx = (repeatCount - 1) * participants.count + winner
        selectedIndex = finalIdx
        totalSegments = extendedList.count
        // Calculer l'angle final pour que le gagnant soit sous la flèche
        let anglePerSegment = 360.0 / Double(totalSegments)
        let finalAngle = -anglePerSegment * (Double(finalIdx) + 0.5)
        // Animation keyframes : rapide puis ralentissement progressif
        let keyframes = 60
        let totalDuration = spinDuration
        var times: [Double] = []
        var values: [Double] = []
        let startAngle = rotation
        for i in 0..<keyframes {
            let t = Double(i) / Double(keyframes-1)
            // Courbe easeOut exponentielle
            let eased = 1 - pow(1-t, 3)
            let angle = startAngle + (finalAngle - startAngle) * eased
            times.append(t * totalDuration)
            values.append(angle)
        }
        animateKeyframes(times: times, values: values) {
            isSpinning = false
            showResult = true
            // Trouver l'index du gagnant dans la liste de base
            let winnerInBase = winner
            onResult(winnerInBase)
        }
    }

    private func animateKeyframes(times: [Double], values: [Double], completion: @escaping () -> Void) {
        guard times.count == values.count, times.count > 1 else { completion(); return }
        var i = 1
        func next() {
            guard i < times.count else { completion(); return }
            let duration = times[i] - times[i-1]
            withAnimation(.linear(duration: duration)) {
                rotation = values[i]
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                i += 1
                next()
            }
        }
        next()
    }
}

// Forme de la roue
struct WheelShape: Shape {
    let segmentCount: Int
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        for i in 0..<segmentCount {
            let startAngle = Angle(degrees: Double(i) * 360.0 / Double(segmentCount) - 90)
            let endAngle = Angle(degrees: Double(i+1) * 360.0 / Double(segmentCount) - 90)
            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
        return path
    }
}

// Un segment de la roue
struct WheelSegment: View {
    let index: Int
    let total: Int
    let label: String
    let isSelected: Bool
    var body: some View {
        GeometryReader { geo in
            let angle = 360.0 / Double(total)
            let start = Double(index) * angle
            let end = start + angle
            ZStack {
                Path { path in
                    let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)
                    let radius = geo.size.width/2
                    path.move(to: center)
                    path.addArc(center: center, radius: radius, startAngle: .degrees(start-90), endAngle: .degrees(end-90), clockwise: false)
                }
                .fill(isSelected ? Color.yellow.opacity(0.7) : Color(hue: Double(index)/Double(total), saturation: 0.5, brightness: 1.0, opacity: 0.7))
                .overlay(
                    Path { path in
                        let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)
                        let radius = geo.size.width/2
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: .degrees(start-90), endAngle: .degrees(end-90), clockwise: false)
                    }
                    .stroke(Color.white, lineWidth: 2)
                )
                // Label
                let labelAngle = (start + angle/2 - 90) * .pi / 180
                let x = geo.size.width / 2.5 * CGFloat(cos(labelAngle))
                let y = geo.size.height / 2.5 * CGFloat(sin(labelAngle))
                Text(label)
                    .font(.headline)
                    .foregroundColor(isSelected ? .black : .primary)
                    .rotationEffect(.degrees(start + angle/2))
                    .offset(x: x, y: y)
            }
        }
    }
}

// Flèche
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
} 
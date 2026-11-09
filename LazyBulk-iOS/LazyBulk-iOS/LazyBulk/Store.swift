import SwiftUI

enum Mode: String, CaseIterable, Identifiable, Codable {
    case home, travel
    var id: String { rawValue }
    var title: String { self == .home ? "At home" : "Out for hours" }
}

struct Saved: Codable {
    var q: [String: [String: Int]] = [:]
    var gear: Set<String> = []
    var kt: [String: Double] = ["home": 3000, "travel": 1200]
    var pt: [String: Double] = ["home": 110, "travel": 45]
}

final class Store: ObservableObject {
    @Published var mode: Mode = .home
    @Published var saved = Saved()
    private let key = "lazybulk.saved.v1"

    init() {
        if let d = UserDefaults.standard.data(forKey: key),
           let s = try? JSONDecoder().decode(Saved.self, from: d) { saved = s }
    }
    private func persist() {
        if let d = try? JSONEncoder().encode(saved) { UserDefaults.standard.set(d, forKey: key) }
    }

    var qty: [String: Int] { saved.q[mode.rawValue] ?? [:] }
    func setQty(_ id: String, _ n: Int) {
        var m = saved.q[mode.rawValue] ?? [:]
        if n <= 0 { m[id] = nil } else { m[id] = min(n, 4) }
        saved.q[mode.rawValue] = m
        persist()
    }
    func toggleGear(_ id: String) {
        if saved.gear.contains(id) { saved.gear.remove(id) } else { saved.gear.insert(id) }
        persist()
    }
    var kcalTarget: Double {
        get { saved.kt[mode.rawValue] ?? 3000 }
        set { saved.kt[mode.rawValue] = newValue; persist() }
    }
    var proteinTarget: Double {
        get { saved.pt[mode.rawValue] ?? 110 }
        set { saved.pt[mode.rawValue] = newValue; persist() }
    }

    var visible: [Food] { Food.all.filter { mode == .home || $0.travel } }

    var totals: (k: Double, p: Double, c: Double, n: Int) {
        var k = 0.0, p = 0.0, c = 0.0, n = 0
        for f in Food.all {
            let x = Double(qty[f.id] ?? 0)
            if x > 0 { k += f.kcal * x; p += f.protein * x; c += f.cost * x; n += 1 }
        }
        return (k, p, c, n)
    }
    var done: Bool {
        let t = totals
        return t.n > 0 && t.k >= kcalTarget * 0.95 && t.p >= proteinTarget
    }
    var message: String {
        let t = totals
        if t.n == 0 { return "Tick items to build your set." }
        if done { return t.k > kcalTarget * 1.2 ? "Over target. Remove something." : "Enough. This is a full set." }
        var gaps: [String] = []
        if t.k < kcalTarget * 0.95 { gaps.append("\(Int(kcalTarget - t.k)) kcal") }
        if t.p < proteinTarget { gaps.append("\(Int(proteinTarget - t.p)) g protein") }
        return "Still need about " + gaps.joined(separator: " and ") + "."
    }
    var suggestions: [Food] {
        let t = totals
        let kg = max(kcalTarget - t.k, 0), pg = max(proteinTarget - t.p, 0)
        return visible.filter { (qty[$0.id] ?? 0) == 0 }
            .map { f -> (Food, Double) in
                let a = pg > 0 ? min(f.protein, pg) / pg : 0
                let b = kg > 0 ? min(f.kcal, kg) / kg : 0
                return (f, a * 0.6 + b * 0.4 - f.cost * 0.02)
            }
            .sorted { $0.1 > $1.1 }
            .prefix(3).map { $0.0 }
    }
}

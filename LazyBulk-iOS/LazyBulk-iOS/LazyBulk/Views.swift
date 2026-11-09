import SwiftUI

private func openLabel(_ listing: Bool, _ url: String) -> String {
    listing ? "FairPrice listing" : (url.contains("lazada") ? "Lazada search" : "FairPrice search")
}

struct LinkLabel: View {
    let url: String, listing: Bool
    var body: some View {
        if let u = URL(string: url) {
            Link(destination: u) { Label(openLabel(listing, url), systemImage: "arrow.up.right") }
                .font(.footnote.weight(.semibold))
        }
    }
}

struct FoodView: View {
    @EnvironmentObject var store: Store
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Mode", selection: $store.mode) {
                        ForEach(Mode.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    Summary()
                    Stepper("Calorie target: \(Int(store.kcalTarget))",
                            value: Binding(get: { store.kcalTarget }, set: { store.kcalTarget = $0 }),
                            in: 800...4500, step: 100)
                    Stepper("Protein target: \(Int(store.proteinTarget)) g",
                            value: Binding(get: { store.proteinTarget }, set: { store.proteinTarget = $0 }),
                            in: 20...200, step: 5)
                }
                if !store.done {
                    Section("Add next to close the gap") {
                        ForEach(store.suggestions) { f in
                            Button { store.setQty(f.id, 1) } label: {
                                Label(f.name, systemImage: "plus.circle.fill")
                            }
                        }
                    }
                }
                ForEach(["Protein", "Carbs", "Extras"], id: \.self) { cat in
                    let items = store.visible.filter { $0.cat == cat }
                    if !items.isEmpty {
                        Section(cat) { ForEach(items) { FoodRow(f: $0) } }
                    }
                }
                Section {
                    Text("Calories, protein and prices are rough estimates for one day’s serving, not label-checked. Listings go to a FairPrice product page; searches open FairPrice or Lazada.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Lazy Bulk")
            .sensoryFeedback(.success, trigger: store.done)
        }
    }
}

struct Summary: View {
    @EnvironmentObject var store: Store
    var body: some View {
        let t = store.totals
        VStack(alignment: .leading, spacing: 10) {
            meter("Calories", t.k, store.kcalTarget, "kcal")
            meter("Protein", t.p, store.proteinTarget, "g")
            HStack {
                Text("Estimated cost").foregroundStyle(.secondary)
                Spacer()
                Text(store.mode == .home
                     ? String(format: "S$%.2f a day, about S$%.0f a week", t.c, t.c * 7)
                     : String(format: "S$%.2f per outing", t.c))
                    .monospacedDigit()
            }.font(.footnote)
            Label(store.message, systemImage: store.done ? "checkmark.seal.fill" : "info.circle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(store.done ? Color.green : Color.primary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
    private func meter(_ title: String, _ v: Double, _ target: Double, _ unit: String) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(title).font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(Int(v)) / \(Int(target)) \(unit)").font(.subheadline).monospacedDigit()
            }
            ProgressView(value: min(v, target), total: max(target, 1)).tint(.green)
        }
    }
}

struct FoodRow: View {
    @EnvironmentObject var store: Store
    let f: Food
    var body: some View {
        let n = store.qty[f.id] ?? 0
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Button { store.setQty(f.id, n == 0 ? 1 : 0) } label: {
                    Image(systemName: n > 0 ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(n > 0 ? Color.green : Color.secondary)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(f.name), \(n > 0 ? "selected" : "not selected")")
                VStack(alignment: .leading, spacing: 2) {
                    Text(f.name).font(.body.weight(.semibold))
                    Text("\(Int(f.kcal)) kcal · \(String(format: "%.0f", f.protein)) g protein · about S$\(String(format: "%.2f", f.cost)) per \(f.unit)")
                        .font(.footnote).foregroundStyle(.secondary)
                    if !f.tip.isEmpty { Text(f.tip).font(.footnote).foregroundStyle(.secondary) }
                }
            }
            HStack {
                if n > 0 {
                    Stepper("Servings: \(n)", value: Binding(get: { n }, set: { store.setQty(f.id, $0) }), in: 1...4)
                        .font(.subheadline)
                }
                if n == 0 { Spacer() }
                LinkLabel(url: f.url, listing: f.listing)
            }
        }
        .padding(.vertical, 2)
    }
}

struct GearView: View {
    @EnvironmentObject var store: Store
    var body: some View {
        NavigationStack {
            List(Gear.all) { g in
                let on = store.saved.gear.contains(g.id)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 12) {
                        Button { store.toggleGear(g.id) } label: {
                            Image(systemName: on ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundStyle(on ? Color.green : Color.secondary)
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(g.name), \(on ? "selected" : "not selected")")
                        VStack(alignment: .leading, spacing: 2) {
                            Text(g.name).font(.body.weight(.semibold))
                            Text("\(g.why) \(g.price)").font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                    LinkLabel(url: g.url, listing: false)
                }
            }
            .navigationTitle("Containers")
        }
    }
}

struct MyListView: View {
    @EnvironmentObject var store: Store
    var body: some View {
        let m = store.mode == .home ? 7 : 1
        let items = Food.all.filter { (store.qty[$0.id] ?? 0) > 0 }
        let gear = Gear.all.filter { store.saved.gear.contains($0.id) }
        NavigationStack {
            List {
                Section(store.mode == .home ? "FairPrice, 1 week" : "FairPrice, per outing") {
                    if items.isEmpty {
                        ContentUnavailableView("Nothing ticked yet", systemImage: "cart",
                                               description: Text("Tick foods on the Food tab and they show up here."))
                    }
                    ForEach(items) { f in
                        let x = (store.qty[f.id] ?? 0) * m
                        VStack(alignment: .leading, spacing: 4) {
                            Text(f.name).font(.body.weight(.semibold))
                            Text("\(x) × \(f.unit) · about S$\(String(format: "%.2f", f.cost * Double(x)))")
                                .font(.footnote).foregroundStyle(.secondary)
                            LinkLabel(url: f.url, listing: f.listing)
                        }
                    }
                    if !items.isEmpty {
                        HStack {
                            Text("Food total").fontWeight(.semibold)
                            Spacer()
                            Text(String(format: "about S$%.2f", store.totals.c * Double(m))).monospacedDigit()
                        }
                    }
                }
                Section("Lazada") {
                    if gear.isEmpty { Text("Nothing ticked yet.").foregroundStyle(.secondary) }
                    ForEach(gear) { g in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(g.name).font(.body.weight(.semibold))
                            Text(g.price).font(.footnote).foregroundStyle(.secondary)
                            LinkLabel(url: g.url, listing: false)
                        }
                    }
                }
            }
            .navigationTitle("My list")
        }
    }
}

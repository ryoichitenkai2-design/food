import Foundation

private func enc(_ q: String) -> String { q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? q }
func fairprice(_ q: String) -> String { "https://www.fairprice.com.sg/search?query=" + enc(q) }
func lazada(_ q: String) -> String { "https://www.lazada.sg/catalog/?q=" + enc(q) }
private let fpp = "https://www.fairprice.com.sg/product/"

struct Food: Identifiable {
    let id: String, cat: String, name: String
    let kcal: Double, protein: Double, cost: Double
    let unit: String, url: String, listing: Bool, travel: Bool, tip: String

    static func f(_ id: String, _ cat: String, _ name: String, _ k: Double, _ p: Double, _ c: Double,
                  _ unit: String, _ url: String, listing: Bool = false, travel: Bool, _ tip: String = "") -> Food {
        Food(id: id, cat: cat, name: name, kcal: k, protein: p, cost: c, unit: unit, url: url,
             listing: listing, travel: travel, tip: tip)
    }

    static let all: [Food] = [
        f("rte", "Protein", "Ready-to-eat chicken breast 90g", 107, 22.6, 3.1, "pack",
          fpp + "delicato-chicken-breast-smoked-90g-13270266", listing: true, travel: false, "Microwave 55 sec or eat cold. Keep chilled."),
        f("fch", "Protein", "Frozen chicken breast (200g raw, about 150g cooked)", 250, 46, 2.0, "serving",
          fpp + "betagro-iqf-frozen-chicken-skinless-boneless-breast-1kg-13262040", listing: true, travel: false, "Air fry about 180°C for 15–20 min. No pink inside."),
        f("tun", "Protein", "Tuna flakes in water 160g", 120, 26, 2.7, "can",
          fpp + "fairprice-tuna-flakes-in-water-160g-13256630", listing: true, travel: true, "Finish the can in one go."),
        f("egg", "Protein", "Boiled eggs ×2", 155, 13, 0.8, "2 eggs", fairprice("eggs"), travel: false, "Boil a tray once a week."),
        f("yog", "Protein", "Greek yogurt 150g", 100, 15, 2.0, "cup", fairprice("greek yogurt plain"), travel: false, "Needs a fridge."),
        f("sal", "Protein", "Frozen salmon fillet (about 120g)", 250, 27, 3.5, "fillet", fairprice("salmon fillet frozen"), travel: false, "Air fry 180°C for 10–12 min. Eat within 2 days."),
        f("mlk", "Protein", "UHT low-fat milk 250ml", 120, 8, 0.9, "pack", fairprice("uht low fat milk"), travel: true, "Shelf-stable until opened."),
        f("oat", "Carbs", "Oats 80g", 300, 11, 0.6, "serving", fairprice("rolled oats"), travel: true, "Microwave with milk, or add hot water."),
        f("ric", "Carbs", "Rice, 300g cooked", 390, 8, 0.4, "serving", fairprice("jasmine rice"), travel: false, "Fridge 2 days at most. Freeze the rest."),
        f("rpk", "Carbs", "Microwave rice pack 150g", 200, 4, 1.5, "pack", fairprice("microwave rice"), travel: true, "Fine unopened at room temperature."),
        f("swp", "Carbs", "Sweet potato 250g", 215, 4, 1.0, "serving", fairprice("sweet potato"), travel: false, "Air fry chunks at 180°C for about 20 min."),
        f("brd", "Carbs", "Wholemeal bread, 2 slices", 160, 8, 0.4, "2 slices", fairprice("wholemeal bread"), travel: true),
        f("ban", "Carbs", "Banana", 105, 1, 0.4, "banana", fairprice("banana"), travel: true),
        f("pnb", "Extras", "Peanut butter, 2 tbsp", 190, 8, 0.5, "serving", fairprice("peanut butter"), travel: true, "Pick a low-sugar one."),
        f("alm", "Extras", "Almonds 20g", 115, 4, 0.8, "serving", fairprice("almonds unsalted"), travel: true),
        f("brc", "Extras", "Frozen broccoli 100g", 35, 3, 0.8, "serving", fairprice("frozen broccoli"), travel: false, "Microwave 3–4 min or air fry from frozen."),
        f("bar", "Extras", "Low-sugar protein or granola bar", 200, 10, 2.0, "bar", fairprice("protein bar"), travel: true, "Backup only."),
    ]
}

struct Gear: Identifiable {
    let id: String, name: String, why: String, price: String, url: String
    static let all: [Gear] = [
        Gear(id: "g3", name: "3-compartment glass containers (4–5 pack)", why: "Rice, protein and extras. Microwave and freezer safe, for home batches.", price: "about S$13–45", url: lazada("3 compartment glass meal prep container")),
        Gear(id: "bt", name: "BPA-free bento box", why: "Lighter and leak-resistant for carrying.", price: "about S$8–26", url: lazada("bento lunch box 3 compartment bpa free")),
        Gear(id: "bg", name: "Insulated lunch bag", why: "Keeps chilled food cooler for a few hours.", price: "about S$10–25", url: lazada("insulated lunch bag")),
        Gear(id: "ic", name: "Reusable ice packs ×2", why: "Freeze overnight. Use two for outings over 2 hours.", price: "about S$5–12", url: lazada("lunch box ice pack reusable")),
        Gear(id: "vj", name: "Vacuum food jar 500–700ml", why: "Preheat with boiling water, fill steaming hot, eat within 4–6 hours.", price: "about S$20–40", url: lazada("vacuum insulated food jar 500ml")),
        Gear(id: "fz", name: "Small freezer rice-portion boxes", why: "Freeze rice and chicken in single portions.", price: "about S$5–15", url: lazada("freezer rice portion container")),
        Gear(id: "bo", name: "Water bottle 1L+", why: "Aim for 2.5–3L a day.", price: "about S$8–20", url: lazada("water bottle 1l bpa free")),
        Gear(id: "th", name: "Digital food thermometer (optional)", why: "Chicken should reach 74°C.", price: "about S$8–15", url: lazada("digital food thermometer")),
    ]
}

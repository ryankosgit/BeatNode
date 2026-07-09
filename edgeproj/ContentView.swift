import SwiftUI
import Foundation

// MARK: - Models
struct Track: Identifiable, Codable, Hashable {
    var id = UUID()
    let title: String
    let artist: String
    let bpm: Double
    let key: String
    
    var keyValue: Int {
        Int(key.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case title, artist, bpm, key
    }
}

// MARK: - Logic Engine
class MatchManager: ObservableObject {
    @Published var searchText: String = ""
    @Published var currentSong: Track?
    @Published var recommendations: [Track] = []
    @Published var library: [Track] = []
    @Published var isProcessing: Bool = false
    
    private var playedHistory: Set<String> = []

    var filteredSuggestions: [Track] {
        guard !searchText.isEmpty else { return [] }
        return library.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.artist.localizedCaseInsensitiveContains(searchText)
        }
    }

    init() {
        loadLibraryFromCSV()
    }

    private func loadLibraryFromCSV() {
        guard let path = Bundle.main.path(forResource: "dj_library", ofType: "csv"),
              let content = try? String(contentsOfFile: path) else {
            print("Error: dj_library.csv not found.")
            return
        }
        
        var rows = content.components(separatedBy: "\n")
        if rows.isEmpty { return }
        rows.removeFirst()
        
        self.library = rows.compactMap { row in
            let columns = row.components(separatedBy: ",")
            guard columns.count >= 4 else { return nil }
            
            return Track(
                title: columns[0].trimmingCharacters(in: .whitespaces),
                artist: columns[1].trimmingCharacters(in: .whitespaces),
                bpm: Double(columns[2].trimmingCharacters(in: .whitespaces)) ?? 120.0,
                key: columns[3].trimmingCharacters(in: .whitespaces)
            )
        }
    }

    // Single source of truth for track selection
    func selectTrack(_ track: Track) {
        self.isProcessing = true
        self.currentSong = track
        self.playedHistory.insert(track.title)
        self.searchText = ""
        
        // Local Inference logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.generateRecommendations(for: track)
            self.isProcessing = false
        }
    }

    private func generateRecommendations(for current: Track) {
        let candidates = library.filter { !playedHistory.contains($0.title) }
        
        let sorted = candidates.sorted { (t1, t2) -> Bool in
            let bpmDist1 = abs(t1.bpm - current.bpm)
            let bpmDist2 = abs(t2.bpm - current.bpm)
            
            let keyDist1 = min(abs(t1.keyValue - current.keyValue), 12 - abs(t1.keyValue - current.keyValue))
            let keyDist2 = min(abs(t2.keyValue - current.keyValue), 12 - abs(t2.keyValue - current.keyValue))
            
            let score1 = (bpmDist1 * 0.3) + (Double(keyDist1) * 0.7)
            let score2 = (bpmDist2 * 0.3) + (Double(keyDist2) * 0.7)
            
            return score1 < score2
        }
        
        self.recommendations = Array(sorted.prefix(3))
    }
}


struct RecommendationRow: View {
    let track: Track
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(track.title)
                    .font(.subheadline).bold()
                    .foregroundColor(.white) // Visible on blue
                Text(track.artist)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(track.formattedBPM) BPM")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(track.key)
                    .font(.system(.caption2, design: .monospaced))
                    .bold()
                    .foregroundColor(.blue)
            }
        }
    }
}



struct RecommendationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10) // Give the row some breathing room
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.15) : Color.gray.opacity(0.05))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0) // Suble "click" scale
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension Track {
    var formattedBPM: String {
        String(format: "%.1f", bpm)
    }
}


struct ContentView: View {
    @StateObject var manager = MatchManager()
    let logoBlue = Color(red: 0.05, green: 0.1, blue: 0.2)

    var body: some View {
        NavigationStack {
            ZStack {
                logoBlue.ignoresSafeArea()
                
                List {
                    // SECTION 1: NOW PLAYING
                    if let current = manager.currentSong {
                        Section(header: Text("Currently Playing").foregroundColor(.white.opacity(0.6))) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(current.title).font(.headline).foregroundColor(.white)
                                    Text(current.artist).font(.subheadline).foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(current.formattedBPM) BPM").font(.system(.caption, design: .monospaced)).foregroundColor(.white.opacity(0.6))
                                    Text(current.key).font(.system(.caption, design: .monospaced)).bold().foregroundColor(.blue)
                                }
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                    }

                    // SECTION 2: SUGGESTIONS
                    if !manager.recommendations.isEmpty {
                        Section(header: Text("Suggestions").foregroundColor(.white.opacity(0.6))) {
                            ForEach(manager.recommendations) { track in
                                Button(action: {
                                    manager.selectTrack(track)
                                }) {
                                    RecommendationRow(track: track)
                                }
                                .buttonStyle(RecommendationButtonStyle())
                                .listRowBackground(Color.clear)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("BeatNode")
            // CHANGE THIS: .automatic allows the "Big to Small" transition
            .navigationBarTitleDisplayMode(.automatic)
            .searchable(text: $manager.searchText, prompt: "Search library...")
            .searchSuggestions {
                ForEach(manager.filteredSuggestions) { suggestion in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(suggestion.title).foregroundColor(.white)
                            Text(suggestion.artist).font(.caption).foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                        Text(suggestion.key).font(.system(.caption2, design: .monospaced)).foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        manager.selectTrack(suggestion)
                    }
                    .listRowBackground(logoBlue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

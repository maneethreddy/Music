import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Song] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = MusicAPIService()
    private var cancellables = Set<AnyCancellable>()
    private var searchDebounceTimer: Timer?
    private weak var musicPlayerViewModel: MusicPlayerViewModel?
    
    init(musicPlayerViewModel: MusicPlayerViewModel? = nil) {
        self.musicPlayerViewModel = musicPlayerViewModel
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] searchTerm in
                self?.performSearch(searchTerm)
            }
            .store(in: &cancellables)
    }
    
    func performSearch(_ query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Try to parse artist and title from search query
        let components = query.components(separatedBy: " - ")
        let artist = components.count > 1 ? components[0].trimmingCharacters(in: .whitespaces) : ""
        let title = components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : query
        
        if !artist.isEmpty && !title.isEmpty {
            // Search by artist and title
            searchByArtistAndTitle(artist: artist, title: title)
        } else {
            // Search by general query
            searchByQuery(query)
        }
    }
    
    private func searchByArtistAndTitle(artist: String, title: String) {
        apiService.searchTrackByArtistAndTitle(artist: artist, title: title)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] songs in
                    self?.searchResults = songs
                }
            )
            .store(in: &cancellables)
    }
    
    private func searchByQuery(_ query: String) {
        apiService.searchTracks(query: query)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] songs in
                    self?.searchResults = songs
                }
            )
            .store(in: &cancellables)
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        errorMessage = nil
    }
    
    func addToQueue(_ song: Song) {
        // This will be handled by the parent ViewModel
    }
    
    func playSong(_ song: Song) {
        musicPlayerViewModel?.play(song: song)
    }
} 
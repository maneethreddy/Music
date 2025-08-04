import Foundation
import Combine

protocol MusicPlayerProtocol {
    var currentSong: Song? { get }
    var playbackState: PlaybackState { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    
    var playbackStatePublisher: AnyPublisher<PlaybackState, Never> { get }
    var currentTimePublisher: AnyPublisher<TimeInterval, Never> { get }
    var currentSongPublisher: AnyPublisher<Song?, Never> { get }
    
    func play(song: Song) -> AnyPublisher<Void, Never>
    func pause() -> AnyPublisher<Void, Never>
    func resume() -> AnyPublisher<Void, Never>
    func stop() -> AnyPublisher<Void, Never>
    func seek(to time: TimeInterval) -> AnyPublisher<Void, Never>
    func setVolume(_ volume: Float) -> AnyPublisher<Void, Never>
} 
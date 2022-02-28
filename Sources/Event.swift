import Foundation

public enum Event: String, Codable {
  case PLAY = "play"
  case RESUME = "resume"
  case READY = "ready"
  case PAUSE = "pause"
  case END = "end"
  case SEEK_FORWARD = "seek.forward"
  case SEEK_BACKWARD = "seek.backward"
}

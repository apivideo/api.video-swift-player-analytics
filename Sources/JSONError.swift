import Foundation

public enum JSONError: Error {
    case serializationError(String)
    case deserializationError(String)
}

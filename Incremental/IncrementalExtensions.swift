import Foundation

// MARK: - General

extension I {
  public func filterMap<B>(eq: @escaping (B, B) -> Bool, _ transform: @escaping (A) -> B?) -> I<B> {
    let target = I<B>(eq: eq)
    let reader = AnyReader { [unowned target] in
      if let newValue = transform(self.value) {
        target.write(newValue)
      }
      return target
    }
    target.strongReferences.add(addReader(reader))
    return target
  }
}

// MARK: - Optionals

public protocol OptionalProtocol {
  associatedtype Wrapped

  init(reconstructing value: Wrapped?)
  var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
  public var optional: Wrapped? {
    return self
  }

  public init(reconstructing value: Wrapped?) {
    self = value
  }
}

extension I where A: OptionalProtocol {
  public func skipNil(eq: @escaping (A.Wrapped,A.Wrapped) -> Bool) -> I<A.Wrapped> {
    return filterMap(eq: eq, { $0.optional })
  }
}

extension I where A: OptionalProtocol, A.Wrapped: Equatable {
  public func skipNil() -> I<A.Wrapped> {
    return skipNil(eq: ==)
  }
}

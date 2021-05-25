import Foundation
import Coding

struct User {
    let id: UUID
    let name: String
    let age: Int
    let pets: [Pet]
}

struct Pet {
    let name: String
}

extension User {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case age
        case pets
    }
}

extension Pet {
    enum CodingKeys: String, CodingKey {
        case name
    }
}

extension Decoding where Value == Pet {
    static var name = Decoding<String>
        .withKey(Pet.CodingKeys.name)
    
    static var standard: Self {
        name.map(Pet.init)
    }
}

extension Encoding where Value == Pet {
    static var name: Self = Encoding<String>
        .withKey(Pet.CodingKeys.name)
        .pullback(\.name)
    
    static var standard: Self {
        combine(name)
    }
}

extension Decoding where Value == User {
    static var id = Decoding<UUID>
        .withKey(User.CodingKeys.id)
    
    static var name = Decoding<String>
        .withKey(User.CodingKeys.name)
    
    static var age = Decoding<Int>
        .optionalWithKey(User.CodingKeys.age)
        .replaceNil(with: 100)
    
    static var pets = Decoding<Pet>.arrayOf(.standard)
        .withKey(User.CodingKeys.pets)
    
    static var standard: Self {
//        zip(id, name)
//            .map(User.init)
//
        zip(with: User.init)(id, name, age, pets)
    }
}

extension Encoding where Value == User {
    static var id: Self = Encoding<UUID>
        .withKey(User.CodingKeys.id)
        .pullback(\.id)
    
    static var name: Self = Encoding<String>
        .withKey(User.CodingKeys.name)
        .pullback(\.name)
    
    static var age: Self = Encoding<Int>
        .withKey(User.CodingKeys.age)
        .pullback(\.age)
    
    static var pets: Self = Encoding<[Pet]>
        .arrayOf(.standard)
        .withKey(User.CodingKeys.pets)
        .pullback(\.pets)
    
    static var standard: Self {
        combine(id, name, age, pets)
    }
}

let ben = User(id: UUID(), name: "Ben", age: 40, pets: [
    .init(name: "Oliver"),
    .init(name: "Chewie")
])

let enc = JSONEncoder()
enc.outputFormatting = .prettyPrinted

let data = try! enc.encode(ben, as: .standard)
print(String(data: data, encoding: .utf8)!)

let json = """
    {
      "id" : "80699353-5C77-4607-BA73-78544E267656",
      "name" : "Ben",
      "age" : 40,
    "pets" : [
        {
          "name" : "Oliver"
        },
        {
          "name" : "Chewie"
        }
      ]
    }
    """

let dec = JSONDecoder()

let user: User = try! dec.decode(json.data(using: .utf8)!, as: .standard)
print(user)

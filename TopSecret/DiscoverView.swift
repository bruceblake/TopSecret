import SwiftUI
import Foundation
import Combine
import CoreLocation


struct DiscoverView : View{
    @StateObject var placeVM = PlacesViewModel()
    @State var selectedOption : Int = 0
    @State var selectedRadiusOption : Int = 0
    @State var radius: Int = 100
    @State var type : String = "restaurant"
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var eventVM = EventsTabViewModel()
    let options = ["Open to Friends", "Open to Mutuals", "Invite Only", "Discover"]
    let radiusOptions = ["Within 1 mile", "Within 5 miles", "Within 10 miles", "Any"]
    @State var searchText : String = ""
    
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    
    func getRadiusInMiles(radius: Int) -> Double{
        round(Double(radius / 1609))
    }
    var body: some View {
        ZStack{
            VStack{
                //search bar
                SearchBar(text: $searchText, placeholder: "search for events", onSubmit: {
                    //todo
                })
                HStack(spacing: 10){
                    //filter
                    Menu {
                        VStack{
                            ForEach(options, id: \.self){ option in
                                Button(action:{
                                    if option == options[0]{
                                        withAnimation{
                                            selectedOption = 0
                                        }
                                    }
                                    else if option == options[1]{
                                        withAnimation{
                                            selectedOption = 1
                                        }
                                    }
                                    else if option == options[2]{
                                        withAnimation{
                                            selectedOption = 2
                                        }
                                    }
                                    
                                    else if option == options[3]{
                                        withAnimation{
                                            selectedOption = 3
                                        }
                                    }
                                },label:{
                                    Text(option)
                                })
                            }
                        }
                    } label: {
                        HStack{
                            Text("\(options[selectedOption])").foregroundColor(FOREGROUNDCOLOR)
                            Image(systemName: "chevron.down")
                        }.padding(5).background(RoundedRectangle(cornerRadius: 12).stroke(Color("Color"), lineWidth: 2))
                    }
                    
                    Menu {
                        VStack{
                            ForEach(radiusOptions, id: \.self){ option in
                                Button(action:{
                                    if option == radiusOptions[0]{
                                        withAnimation{
                                            selectedRadiusOption = 0
                                        }
                                    }
                                    else if option == radiusOptions[1]{
                                        withAnimation{
                                            selectedRadiusOption = 1
                                        }
                                    }
                                    else if option == radiusOptions[2]{
                                        withAnimation{
                                            selectedRadiusOption = 2
                                        }
                                    }
                                    
                                    else if option == radiusOptions[3]{
                                        withAnimation{
                                            selectedRadiusOption = 3
                                        }
                                    }
                                },label:{
                                    Text(option)
                                })
                            }
                        }
                    } label: {
                        HStack{
                            Text("\(radiusOptions[selectedRadiusOption])").foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            Image(systemName: "chevron.down")
                        }.padding(5).background(RoundedRectangle(cornerRadius: 12).stroke(Color("Color"), lineWidth: 2))
                    }
                    Button(action:{
                        
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "slider.horizontal.3").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                }.padding(5)
                VStack{
                    ScrollView{
                       
                    }
                }
            }
        }.edgesIgnoringSafeArea(.all).frame(width: UIScreen.main.bounds.width).onAppear{
            placeVM.searchNearbyPlaces(radius: radius, type: type)
        }
    }
}

class PlacesViewModel : ObservableObject {
    
   
    @Published var places: [Place] = []
    @Published var isLoading: Bool = false
    let apiKey = "AIzaSyDlMCxtpHh46hxipZvRmFgE4NK7SwgiYHI"

    func searchNearbyPlaces(radius: Int, type: String){
    
        self.isLoading = true
        guard let url = URL(string:     "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=38.617929,-77.388798&radius=\(radius)&key=\(apiKey)&type=\(type)") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url)  { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do{
                let results = try JSONDecoder().decode(Result.self, from: data)
                DispatchQueue.main.async{
                    self?.places = results.results
              
                        self?.isLoading = false
                    
                }
            }catch{
                print(error)
            }
        }
        task.resume()
    }
}




struct Result: Codable {
    var htmlAttributions: [JSONAny]
    var results: [Place]
    var status: String

    enum CodingKeys: String, CodingKey {
        case htmlAttributions = "html_attributions"
        case results, status
    }
}

struct Place: Hashable, Codable{
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.geometry == rhs.geometry &&
               lhs.icon == rhs.icon &&
               lhs.iconBackgroundColor == rhs.iconBackgroundColor &&
               lhs.iconMaskBaseURI == rhs.iconMaskBaseURI &&
               lhs.name == rhs.name &&
               lhs.placeID == rhs.placeID &&
               lhs.reference == rhs.reference &&
               lhs.scope == rhs.scope &&
               lhs.types == rhs.types &&
               lhs.vicinity == rhs.vicinity
      }
    
    var geometry: Geometry
    var icon: String
    var iconBackgroundColor: String
    var iconMaskBaseURI: String
    var name, placeID, reference, scope: String
    var types: [String]
    var vicinity: String

    enum CodingKeys: String, CodingKey {
        case geometry, icon
        case iconBackgroundColor = "icon_background_color"
        case iconMaskBaseURI = "icon_mask_base_uri"
        case name
        case placeID = "place_id"
        case reference, scope, types, vicinity
    }
}

// MARK: - Geometry
struct Geometry: Codable, Hashable {
    static func == (lhs: Geometry, rhs: Geometry) -> Bool {
        return lhs.location == rhs.location &&
        lhs.viewport == rhs.viewport
    }
    
    var location: Location
    var viewport: Viewport
}

// MARK: - Location
struct Location: Codable, Hashable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.lat == rhs.lat &&
        lhs.lng == rhs.lng
    }
    var lat, lng: Double
}

// MARK: - Viewport
struct Viewport: Codable, Hashable {
    static func == (lhs: Viewport, rhs: Viewport) -> Bool {
        return lhs.northeast == rhs.northeast &&
        lhs.southwest == rhs.southwest
    }
    var northeast, southwest: Location
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}

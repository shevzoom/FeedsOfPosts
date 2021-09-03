//
//  APICaller.swift
//  FeedsOfPosts
//
//  Created by Глеб Шевченко on 23.07.2021.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
                          
    public func getTopStories(lastID: Int = 0, lastSortingValue: Double = 0, completion: @escaping (Result<[IsResult], Error>) -> Void) {
        
        guard var headLineURL = URLComponents(string: "https://api.tjournal.ru/v2.0/timeline") else { return }

        headLineURL.queryItems = [
            URLQueryItem(name: "allSite", value: "false"),
            URLQueryItem(name: "sorting", value: "hotness"),
            URLQueryItem(name: "lastID", value: "\(lastID)"),
            URLQueryItem(name: "lastSortingValue", value: "\(lastSortingValue)")
        ]
        
        guard let url = headLineURL.url else { return }
        
        let task = URLSession.shared.dataTask(with: url) {data, _, error in
//            print("You are on \(Thread.isMainThread ? "MAIN" : "BACKGROUND") thread.")
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                
                do {
                    let json = try JSONDecoder().decode(APIResponce.self, from: data)
                    completion(.success([json.result]))
//                    print("obj in json: \(json.result.items.count)")
//                    dump([json.result])
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

// Model
struct APIResponce: Codable {
    let result: IsResult
}

struct IsResult: Codable {
    let items: [ResultItem]
    let lastID: Int
    let lastSortingValue: Double
    
    enum CodingKeys: String, CodingKey {
        case items
        case lastID = "lastId"
        case lastSortingValue
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        // т.к. 1-й объект в data nil => filter
        items = (try values.decode([ResultItem].self, forKey: .items)).filter{$0.data != nil}
        lastID = (try values.decode(Int.self, forKey: .lastID))
        lastSortingValue = (try values.decode(Double.self, forKey: .lastSortingValue))
    }
}

struct ResultItem: Codable {
    var data: DataData?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = (try? values.decodeIfPresent(DataData.self, forKey: .data))
    }
}

struct DataData: Codable {
    let author: SubsiteClass?
    let title: String
    let blocks: [Block]?
    let subsite: SubsiteClass?
    
    enum CodingKeys: String, CodingKey {
        case author
        case subsite, title, blocks
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        author = (try? values.decode(SubsiteClass.self, forKey: .author))
        title = (try values.decode(String.self, forKey: .title))
        blocks = (try? values.decode([Block].self, forKey: .blocks))
        subsite = (try? values.decode(SubsiteClass.self, forKey: .subsite))
   }
}

// MARK: - SubsiteClass / Раздел. (ex. "Новости")
struct SubsiteClass: Codable {
    let name: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = (try values.decode(String.self, forKey: .name))
    }
}

struct Block: Codable {
    let data: BlockData

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = (try values.decode(BlockData.self, forKey: .data))
   }
}

// MARK: - BlockData / subtitle - подзаголовок статьи
struct BlockData: Codable {
    let text: String?
    let items: [ItemUnion]?
    
    enum CodingKeys: String, CodingKey {
        case text
        case items
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        text = (try? values.decode(String?.self, forKey: .text))
        items = (try? values.decode([ItemUnion]?.self, forKey: .items))
    }
}

struct ItemUnion: Codable {
    let image: DataImage?
    
    enum CodingKeys: String, CodingKey {
        case image
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        image = (try? values.decode(DataImage.self, forKey: .image))
    }
}

struct DataImage: Codable {
    let data: Image?
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = (try? values.decode(Image.self, forKey: .data))
    }
}

struct Image: Codable {
    let uuid: UUID?
    
    enum CodingKeys: String, CodingKey {
        case uuid
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = (try? values.decode(UUID.self, forKey: .uuid))
    }
}

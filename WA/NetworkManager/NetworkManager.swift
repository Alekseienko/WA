//
//  NetworkManager.swift
//  WA
//
//  Created by alekseienko on 25.10.2022.
//

import Foundation
import MapKit

class NetworkManager {
    private init() {}
    
    static let shared: NetworkManager = NetworkManager()
    
    func getWeather(city: String? = nil, coordinate: CLLocationCoordinate2D? = nil, resault: @escaping ((WeatherModel?) -> ())) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = "/data/2.5/forecast"
        if (city != nil) {
            urlComponents.queryItems = [URLQueryItem(name: "q", value: city), URLQueryItem(name: "appid", value: "e44f197f2125a67b4ca57e7e5a3945a7")]
        } else if coordinate != nil {
            urlComponents.queryItems = [URLQueryItem(name: "lat", value: coordinate?.latitude.description),URLQueryItem(name: "lon", value: coordinate?.longitude.description), URLQueryItem(name: "appid", value: "e44f197f2125a67b4ca57e7e5a3945a7")]
        }
        guard let url = urlComponents.url else {
            print("Some problem with URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession(configuration: .default)
        task.dataTask(with: request) { data, response, error in
            if error == nil {
                var decoderWeatherModel: WeatherModel?
                if data != nil {
                    decoderWeatherModel = try? JSONDecoder().decode(WeatherModel.self, from: data!)
                }
                resault(decoderWeatherModel)
            } else {
                print("Some problem with data")
            }
        }.resume()
    }
}


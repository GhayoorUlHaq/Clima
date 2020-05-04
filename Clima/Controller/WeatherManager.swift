//
//  WeatherManager.swift
//  Clima
//
//  Created by Ghayoor ul Haq on 03/05/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import CoreLocation
import Foundation


// Protocol must be in same file where it will be used
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager {
    // get the open weather API and Replace YOUR_API_KEY in the link below
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=YOUR_API_KEY&units=metric"
    var delegate: WeatherManagerDelegate?
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees ){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString: String) {
        
        //  1. Created Url
        if let url = URL(string: urlString) {
            //  2. Create URL session
            let session = URLSession(configuration: .default)
            // 3. Assign sessan a task
            let task = session.dataTask(with: url, completionHandler: { data, response, error in
                if let e = error {
                    self.delegate?.didFailWithError(error: e)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            })
            // 4. Start task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
           let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

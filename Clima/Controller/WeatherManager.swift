//
//  WeatherManager.swift
//  Clima
//
//  Created by Ghayoor ul Haq on 03/05/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation


// Protocol must be in same file where it will be used
protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
}


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=e72ca729af228beabd5d20e3b7749713&units=metric"
    var delegate: WeatherManagerDelegate?
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        
        //  1. Created Url
        if let url = URL(string: urlString) {
            //  2. Create URL session
            let session = URLSession(configuration: .default)
            // 3. Assign sessan a task
            let task = session.dataTask(with: url, completionHandler: { data, response, error in
                if let e = error {
                    print(e)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(weather: weather)
                    }
                }
            })
            // 4. Start task
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
           let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            print(error)
            return nil
        }
    }
}

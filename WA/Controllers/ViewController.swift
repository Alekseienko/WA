//
//  ViewController.swift
//  WA
//
//  Created by alekseienko on 25.10.2022.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainDateLbl: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var mainTempLbl: UILabel!
    @IBOutlet weak var mainHumidityLbl: UILabel!
    @IBOutlet weak var mainWindLbl: UILabel!
    @IBOutlet weak var windImg: UIImageView!
    @IBOutlet weak var cityNameLbl: UILabel!
    
    // MARK: - PROPERTIES
    let defaults = UserDefaults.standard
    private var weatherData: WeatherModel?
    private var weatherList: [List] = []
    private var timer: Timer?
    var weatherCoordinate: CLLocationCoordinate2D? = nil
    var сity: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaults.bool(forKey: "First Launch") == true {
            defaults.set(true, forKey: "First Launch")
        } else {
            defaults.set(true, forKey: "First Launch")
            defaults.set("Berlin", forKey: "City")
        }
        сity = defaults.string(forKey: "City")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        if let coordinate = weatherCoordinate {
            loadData(coordinate: coordinate)
        } else {
            loadData(city: сity)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize"
        {
                if let newValue = change?[.newKey]{
                    let newSize = newValue as! CGSize
                    self.tableViewHeight.constant = newSize.height
                }
            }
        }
    
    
    // MARK: - FUNCTIONS LOAD DATA
    func loadData(city: String? = nil, coordinate: CLLocationCoordinate2D? = nil) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { [self] _ in
            NetworkManager.shared.getWeather(city: city, coordinate: coordinate ){ resault in
                guard let resault = resault else {return}
                self.weatherData = resault
                let resaultList = Dictionary(grouping: resault.list, by: { Calendar.current.startOfDay(for: Date(timeIntervalSince1970: TimeInterval($0.dt))) }).compactMap { $0.value.last }
                self.weatherList += resaultList.sorted { $0.dt < $1.dt }
                self.defaults.set(resault.city.name, forKey: "City")
                DispatchQueue.main.async {
                    self.cityNameLbl.text = resault.city.name
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            }
        })
    }
}

// MARK: - SETUP TABLE VIEW
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = weatherList[indexPath.row]
        //SET MAIN DATA
        mainDateLbl.text = getDate(date: value.dt, format: "EE, MMM d")
        //SET MAIN TEMP
        mainTempLbl.text = getCelsiusString(kel: value.main.tempMax) + "/" + getCelsiusString(kel: value.main.tempMin)
        //SET MAIN HUMIDITY
        mainHumidityLbl.text = "\(value.main.humidity)%"
        //SET MAIN WIND
        mainWindLbl.text = String(format: "%.1f м/сек", value.wind.speed)
        //SET MAIN IMAGE
        mainImg.image = getWeatherImage(idnumber: value.weather[0].id, pod: value.sys.pod.rawValue)
        //SET IMG WIND
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        let value = weatherList[0]
        mainDateLbl.text = getDate(date: value.dt, format: "EE, MMM d")
        mainTempLbl.text = getCelsiusString(kel: value.main.tempMax) + "/" + getCelsiusString(kel: value.main.tempMin)
        mainHumidityLbl.text = "\(value.main.humidity)%"
        mainWindLbl.text = String(format: "%.1f м/сек", value.wind.speed)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherList.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
        let value = weatherList[indexPath.row]
        //SET DAY
        cell.dayLbl.text = getDate(date: value.dt, format: "EE")
        //SET TEMP
        cell.tempLbl.text = getCelsiusString(kel: value.main.tempMax) + "/" + getCelsiusString(kel: value.main.tempMin)
        //SET IMAGE
        cell.img.image = getWeatherImage(idnumber: value.weather[0].id, pod: value.sys.pod.rawValue)
        //SET SELECTED STYLE
        cell.dayLbl.highlightedTextColor = UIColor(named: "ColorWhiteBlue")
        cell.tempLbl.highlightedTextColor = UIColor(named: "ColorWhiteBlue")
        let selectImage = cell.img.image?.withTintColor(UIColor(named: "ColorWhiteBlue") ?? .red, renderingMode: .alwaysOriginal)
        cell.img.highlightedImage = selectImage
        return cell
    }
}
// MARK: - SETUP COLLECTION VIEW
extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 120)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherData?.list.count ?? 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let value = weatherData?.list.sorted { $0.dt < $1.dt }
        guard let cellValue = value?[indexPath.row] else {
            return cell
        }
        // SET TEMP LABLE
        cell.tempLbl.text = getCelsiusString(kel: cellValue.main.temp)
        //SET DATE LABEL
        cell.timeLbl.text = getDate(date: cellValue.dt, format: "HH")
        // SET IMAGE
        cell.img.image = getWeatherImage(idnumber: cellValue.weather[0].id, pod: cellValue.sys.pod.rawValue)
        return cell
    }
}



// MARK: - UI FUNCTIONS
extension ViewController {
    
    func getWeatherImage(idnumber: Int, pod: String) -> UIImage {
        var imageNameSufix: String
        var imageNamePrefix: String
        
        if pod == "d" {
            imageNamePrefix = "ic_white_day_"
        } else {
            imageNamePrefix = "ic_white_night_"
        }
        switch idnumber {
        case 200...232:
            imageNameSufix = "thunder"
        case 300...321:
            imageNameSufix = "shower"
        case 500...531:
            imageNameSufix = "rain"
        case 600...632:
            imageNameSufix = "cloudy"
        case 800:
            imageNameSufix = "bright"
        case 801...804:
            imageNameSufix = "cloudy"
        default:
            imageNameSufix = ""
        }
        return UIImage(named: imageNamePrefix + imageNameSufix) ?? UIImage()
    }
    
    func getCelsiusString(kel: Double) -> String {
        return String(Int(kel - 273.15)) + "°"
    }
    
    func getDate(date: Int, format: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(date))
        let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = format
        return formatter.string(from: date).uppercased()
    }
}

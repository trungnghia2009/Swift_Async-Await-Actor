//
//  ViewController.swift
//  AsynAwait
//
//  Created by trungnghia on 11/03/2023.
//

///https://fxstudio.dev/async-await-to-fetch-rest-api-swift-5-5/

import UIKit
import Combine

class ViewController: UIViewController {
    
    private let urlString = "https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    private var subscriptions = [AnyCancellable]()
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        viewModel.fetch1()
//        viewModel.fetch2()
//        viewModel.fetch3()
        viewModel.fetch4()
//        loadAPI1()
//        loadAPI2()
        setupObserver()
        configureTableView()
    }
    
    // Test async call 1 -> Must put the codes in DispatchQueue.main.async{}
    private func loadAPI1() {
        let service = ApiService()
        let url = URL(string: urlString)!
        
        service.fetchAPI(url: url) { (result: Result<CategoryResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    if result.drinks.count > 0 {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // Test async call 2 -> No need to call DispatchQueue.main.async{}
    private func loadAPI2() {
        let service = ApiService()
        Task {
            do {
                let url = URL(string: urlString)!
                let result: CategoryResult = try await service.fetchAPI(url: url)
                if result.drinks.count > 0 {
                    print("Success...")
                    tableView.reloadData()
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupObserver() {
        viewModel.onFetch
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
            }.store(in: &subscriptions)
        
        viewModel.onError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                Utils.shared.showAlert(viewController: self, message: error.localizedDescription)
            }.store(in: &subscriptions)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getNumberOfSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.getDrinkForRowAt(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.getSectionName(section: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did selected section: \(indexPath.section), row: \(indexPath.row)")
    }
}

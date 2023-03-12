//
//  AlBumViewController.swift
//  AsynAwait
//
//  Created by trungnghia on 11/03/2023.
//

///https://swiftsenpai.com/swift/async-await-network-requests/

import UIKit
import Combine

class AlbumViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    private var subcriptions = [AnyCancellable]()
    private let viewModel = AlbumViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Album"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.viewModel.fetchAlbums1()
//            self.viewModel.fetchAlbums2()
            self.viewModel.fetchAlbums3()
        }
        setupObserver()
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupObserver() {
        viewModel.onFetchAlbums
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
            }.store(in: &subcriptions)
        
        viewModel.onError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                Utils.shared.showAlert(viewController: self, message: error.localizedDescription)
            }.store(in: &subcriptions)
    }

}

extension AlbumViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.getAlbumForRowAt(indexPath: indexPath)
        return cell
    }
}

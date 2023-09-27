//
//  ViewController.swift
//  CombineIntro
//
//  Created by Obde Willy on 28/02/23.
//

import UIKit
import Combine

class MyCustomTableCell: UITableViewCell {
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.setTitle("Button", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
        return button
    }()
    
    let action = PassthroughSubject<String, Never>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 10, y: 3, width: contentView.frame.size.width - 20, height: contentView.frame.size.height - 6)
    }
    
    @objc private func didTapButton() {
        action.send("Cool!")
    }
}

class ViewController: UIViewController, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(MyCustomTableCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var observers: [AnyCancellable] = []
    private var models = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = view.bounds
        
        view.addSubview(tableView)
        
        tableView.dataSource = self
        
        APICaller.shared.fetchCompanies()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print(error)
                }
                
            }, receiveValue: { [weak self] value in
                
                self?.models = value
                self?.tableView.reloadData()
                
            })
            .store(in: &observers)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyCustomTableCell
        //        cell.textLabel!.text = models[indexPath.row]
        cell.action.sink {
            print($0)
        }
        .store(in: &observers)
        
        return cell
    }
}


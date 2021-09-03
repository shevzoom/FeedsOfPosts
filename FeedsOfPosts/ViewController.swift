//
//  ViewController.swift
//  FeedsOfPosts
//
//  Created by Глеб Шевченко on 22.07.2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()

    private var result = [IsResult]()
    private var viewModels = [NewsTableViewCellViewModel]()
    private var id = 0
    private var sortVal = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        fetchTopStories()
//        self.tableView.tableFooterView?.isHidden = true
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Крафтим модель во View
    private func fetchTopStories(completed: ((Bool) -> Void)? = nil) {
        APICaller.shared.getTopStories(lastID: id, lastSortingValue: sortVal) { [weak self] json in
            switch json {
            case .success(let result):
                self?.result.append(contentsOf: result)
                
                guard let arr = result.first?.items else { return }
              
                self?.viewModels.append(contentsOf: arr.compactMap({ viewModels in
                    
                    guard let uuid = viewModels.data?.blocks?.first(where: {$0.data.text == nil && $0.data.items != nil})?.data.items?.first?.image?.data?.uuid else { return nil }
//                    print("uuid is \(uuid)")

                    return NewsTableViewCellViewModel(
                        name: viewModels.data?.subsite?.name ?? "unknown",
                        author: viewModels.data?.author?.name ?? "No name",
                        title: viewModels.data?.title ?? "NO TITLE",
                        subtitle: viewModels.data?.blocks?.first?.data.text ?? "",
                        imageURL: URL(string: "https://leonardo.osnova.io/\(uuid.uuidString.lowercased())")
                    )
                }))
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                self?.id = result.first?.lastID ?? 0
                self?.sortVal = result.first?.lastSortingValue ?? 0
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Tap to Image ()
    @objc func imageTapped(sender: UITapGestureRecognizer) {
            if sender.state == .ended {
                let imageView = sender.view as! UIImageView
                let newImageView = UIImageView(image: imageView.image)
                let blurEffect = UIBlurEffect(style: .dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                
                newImageView.frame = self.view.bounds
                blurEffectView.frame = self.view.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                newImageView.contentMode = .scaleAspectFit
                newImageView.isUserInteractionEnabled = true
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImage))
                newImageView.addGestureRecognizer(tap)

                self.view.addSubview(blurEffectView)
                self.view.addSubview(newImageView)
                self.navigationController?.isNavigationBarHidden = true
                self.tabBarController?.tabBar.isHidden = true
            }
    }
    
    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
        view.removeBlurEffect()
    }


    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        ///- dequeueReusableCell - подгружает из очереди переиспользуемую ячейку
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identifier,
            for: indexPath
        ) as? NewsTableViewCell else {
                fatalError()
            }
        cell.configure(with: viewModels[indexPath.row])
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        cell.newsImageView.isUserInteractionEnabled = true
        cell.newsImageView.addGestureRecognizer(tap)
        
        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = result.first?.items[indexPath.row]

        guard let url = article?.data?.blocks?.first(where: {$0.data.text == nil && $0.data.items != nil})?.data.items?.first?.image?.data?.uuid
        else { return }

        guard URL(string:"https://leonardo.osnova.io/\(url.uuidString.lowercased())") != nil  else { return }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 510
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModels.count-1 {
            fetchTopStories { success in
                if !success {
                    print("no item for load")
                }
            }
        }
    }
}

extension UIView {
  func removeBlurEffect() {
    let blurredEffectViews = self.subviews.filter{$0 is UIVisualEffectView}
    blurredEffectViews.forEach{ blurView in
      blurView.removeFromSuperview()
    }
  }
}


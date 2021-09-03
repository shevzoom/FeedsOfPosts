//
//  NewsTableViewCell.swift
//  FeedsOfPosts
//
//  Created by Глеб Шевченко on 23.07.2021.
//

import UIKit

class NewsTableViewCellViewModel {
    let name: String
    let author: String
    let title: String
    let subtitle: String
    let imageURL: URL?
    var imageData: Data? = nil
    
    init(
        name: String,
        author: String,
        title: String,
        subtitle: String,
        imageURL: URL?
    ) {
        self.name       = name
        self.author     = author
        self.title      = title
        self.subtitle   = subtitle
        self.imageURL   = imageURL
    }
}

class NewsTableViewCell: UITableViewCell {
    static let identifier = "NewsTableViewCell"
    
    lazy var backView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width+100 , height: 470))
        view.backgroundColor  = UIColor.white
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin]
        return view
    }()

    private let articleName: UILabel = {
        let label           = UILabel()
        label.numberOfLines = 0
        label.textColor     = .black
        label.font          = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let authorName: UILabel = {
        let label           = UILabel()
        label.numberOfLines = 0
        label.textColor     = .black
        label.font          = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    private let newsTitleLabel: UILabel = {
        let label           = UILabel()
        label.numberOfLines = 0
        label.textColor     = .black
        label.font          = .systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label           = UILabel()
        label.numberOfLines = 0
        label.textColor     = .black
        label.font          = .systemFont(ofSize: 17, weight: .light)
        return label
    }()
    
    public let newsImageView: UIImageView = {
        let imageView                 = UIImageView()
        imageView.layer.cornerRadius  = 6
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds       = true
        imageView.backgroundColor     = .secondarySystemBackground
        imageView.contentMode         = .scaleAspectFill
        return imageView
    }()
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xF0F0F0)
        contentView.addSubview(backView)
        contentView.addSubview(articleName)
        contentView.addSubview(authorName)
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(newsImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Constraint
    override func layoutSubviews() {
        super.layoutSubviews()
        
        articleName.translatesAutoresizingMaskIntoConstraints                                           = false
        articleName.centerYAnchor.constraint(equalTo: topAnchor, constant: 20).isActive                 = true
        articleName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive             = true

        authorName.translatesAutoresizingMaskIntoConstraints                                            = false
        authorName.centerYAnchor.constraint(equalTo: topAnchor, constant: 20).isActive                  = true
        authorName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive           = true

        newsTitleLabel.translatesAutoresizingMaskIntoConstraints                                        = false
        newsTitleLabel.topAnchor.constraint(equalTo: authorName.bottomAnchor, constant: 8).isActive     = true
        newsTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive          = true
        newsTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive               = true
        newsTitleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 175).isActive                 = true
        newsTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive       = true

        subtitleLabel.translatesAutoresizingMaskIntoConstraints                                         = false
        subtitleLabel.topAnchor.constraint(equalTo: newsTitleLabel.bottomAnchor, constant: 8).isActive  = true
        subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive           = true
        subtitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive                = true
        subtitleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 75).isActive                   = true
        subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive        = true

        newsImageView.translatesAutoresizingMaskIntoConstraints                                         = false
        newsImageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8).isActive   = true
        newsImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive            = true
        newsImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 230).isActive                  = true
        newsImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive          = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        articleName.text    = nil
        authorName.text     = nil
        newsTitleLabel.text = nil
        subtitleLabel.text  = nil
        newsImageView.image = nil
    }
    
    func configure(with viewModel: NewsTableViewCellViewModel) {
        articleName.text = viewModel.name
        authorName.text = viewModel.author
        newsTitleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        
        // MARK: - configure Image
        if let data = viewModel.imageData {
            newsImageView.image = UIImage(data: data)

        } else if let url = viewModel.imageURL {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in

                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}

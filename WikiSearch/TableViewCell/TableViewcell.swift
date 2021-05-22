//
//  TableViewcell.swift
//  WikiSearch
//
//  Created by saif ahmed on 14/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import UIKit
protocol TableViewCellDataSourceProtocol {
    var imageURL : URL? { get }
    var primaryDescription : String? { get }
    var secondaryDescription : String? { get }
}
class TableViewcell: UITableViewCell {
    
    @IBOutlet var wikiImageView: UIImageView!
    @IBOutlet var secondaryLabel: UILabel!
    @IBOutlet var primaryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        wikiImageView.image = nil
        secondaryLabel.text = nil
        primaryLabel.text = nil
    }
    var indexPath : IndexPath?
    func updateCell(with data : TableViewCellDataSourceProtocol, at indexPath : IndexPath) {
        primaryLabel.text = data.primaryDescription
        secondaryLabel.text = data.secondaryDescription
        self.indexPath = indexPath
        guard let imageURL = data.imageURL else {
            wikiImageView.image = UIImage(imageLiteralResourceName: "noImage")
            return }
        URLSession.shared.dataTask(with: imageURL) {[weak self] (data, response, error) in
            guard let imageData = data, error == nil, self?.indexPath == indexPath else { return }
            DispatchQueue.main.async {
                self?.wikiImageView.image = UIImage(data: imageData)
            }
        }.resume()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

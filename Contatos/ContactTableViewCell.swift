//
//  ContactTableViewCell.swift
//  Contatos
//
//  Created by Usuário Convidado on 11/02/17.
//  Copyright © 2017 FIAP. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmails: UILabel!
    @IBOutlet weak var lbPhones: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func clear() {
        ivProfile.image = UIImage(named: "contact")
        lbName.text = ""
        lbEmails.text = ""
        lbPhones.text = ""
    }

}

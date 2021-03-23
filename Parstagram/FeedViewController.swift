//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Andy Celdo on 3/17/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate{

    // MARK: - Initializing Variables
    
    //IBOutlet variables
    @IBOutlet weak var tableView: UITableView!
        
    //Other variables
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    let commentBar = MessageInputBar()
    var showCommentBar = false
    
    var refreshCtrl: UIRefreshControl!
    var scrollCounter: Int!
    var numOfPrevPosts: Int!
    var reloadBool: Bool!
    
    // MARK: - IBActions
    @IBAction func onLogout(_ sender: Any) {
    
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
    
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        //UIApplication.shared.delegate
        
        delegate.window?.rootViewController = loginViewController
        
    }
    
    // MARK: - Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad()")
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
    
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        tableView.insertSubview(refreshCtrl, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear()")
        scrollCounter = 3
        reloadBool = false
        numOfPrevPosts = 3
        
        let query = PFQuery(className: "Posts2")
        query.includeKeys(["author", "comments", "comments.author"])
        
        query.limit = scrollCounter
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            } else {
                print("Error: \(String(describing: error))")
            }
        }
    }
    
    // MARK: - For MessageInputBar import
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showCommentBar
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create the comment
        let comment = PFObject(className: "Comments")
        
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved!")
            } else {
                print("Error saving comment \(String(describing: error))")
            }
        }
        
        tableView.reloadData()
    
        //Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    // MARK: - Tableview functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlStr = imageFile.url!
            let url = URL(string: urlStr)!
            
            cell.photoView.af.setImage(withURL: url)
            return cell
            
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        print("tableView willDisplay is called")
        print("row: " + String(indexPath.row) + "section: " + String(indexPath.section) + "   posts.count: " + String(posts.count))
        print("scrollCounter: " + String(scrollCounter))
        if (indexPath.section + 1 == posts.count && indexPath.row + 1 == tableView.numberOfRows(inSection: indexPath.section)) {
            if (reloadBool == true) {
                loadMore()
                reloadBool = false
            } else if posts.count == numOfPrevPosts {
                reloadBool = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comment = (post["comments"] as? [PFObject]) ?? []

        if indexPath.row == comment.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
    }
    
    // MARK: - Other functions
    @objc func keyboardWillBeHidden(note: Notification) {
        print("keyboardWillBeHidden is called")
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }

    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        print("run is called")
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
        
        tableView.reloadData()
        refreshCtrl.endRefreshing()
    }
    
    @objc
    func onRefresh() {
        print("onRefresh called")
        run(after: 2) {
            self.refreshCtrl.endRefreshing()
        }
    }
    
    func loadMore() {
        print("loadMore is called")
        scrollCounter += 3
        numOfPrevPosts = posts.count
        
        let query = PFQuery(className: "Posts2")
        query.includeKeys(["author", "comments", "comments.author"])

        query.limit = scrollCounter
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
            else {
                print("Error: \(String(describing: error))")
            }
        }
        print()
        print("stringCounter: " + String(scrollCounter))
        reloadBool = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

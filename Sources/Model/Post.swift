//
//  Post.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import SwiftyJSON
import YapDatabase

public let UpdatePostCommentCountNotification = TypedNotification<Comment>(name: "UpdatePostCommentCountNotification")

@objc
public protocol Authorable {
    var createdAt : NSDate { get }
    var groupId: String { get }
    var author: User? { get }
}

let PostVersion = 1

public final class Post: JSONAble, Authorable {
    public let version: Int = PostVersion

    // active record
    public let id: String
    public let createdAt: NSDate
    // required
    public let href: String
    public let token: String
    public let contentWarning: String
    public let allowComments: Bool
    public let summary: [Regionable]
    // optional
    public var content: [Regionable]?
    public var repostContent: [Regionable]?
    public var repostId: String?
    public var repostPath: NSURL?
    public var repostViaId: String?
    public var repostViaPath: NSURL?
    public var viewsCount: Int?
    public var commentsCount: Int?
    public var repostsCount: Int?
    // links
    public var assets: [String: Asset]?
    public var author: User? {
        println("author post \(id) links: \(links)")
        return getLinkObject("author") as? User
    }
    // nested resources
    public var comments: [Comment]? {
        if let comments = getLinkArray(MappingType.CommentsType.rawValue) as? [Comment] {
            for comment in comments {
                comment.addLinkObject("parent_post", key: id, collection: MappingType.PostsType.rawValue)
            }
            return comments
        }
        return nil
    }
    // links post with comments
    public var groupId:String { return id }
    // computed properties
    public var shareLink:String? {
        get {
            if let author = self.author {
                return "\(ElloURI.baseURL)/\(author.username)/post/\(self.token)"
            }
            else {
                return nil
            }
        }
    }
    public var collapsed = false
    private var commentCountNotification: NotificationObserver?


// MARK: Initialization

    public init(id: String,
        createdAt: NSDate,
        href: String,
        token: String,
        contentWarning: String,
        allowComments: Bool,
        summary: [Regionable]
        )
    {
        // active record
        self.id = id
        self.createdAt = createdAt
        // required
        self.href = href
        self.token = token
        self.contentWarning = contentWarning
        self.allowComments = allowComments
        self.summary = summary
        super.init()
        collapsed = self.contentWarning != ""
        registerNotifications()
    }

    deinit {
        self.unregisterNotifications()
    }

    private func registerNotifications() {
        commentCountNotification = NotificationObserver(notification: UpdatePostCommentCountNotification) { comment in
            if comment.postId == self.id {
                if let count = self.commentsCount {
                    self.commentsCount = count + 1
                }
                else {
                    self.commentsCount = 1
                }
            }
        }
    }

    private func unregisterNotifications() {
        if let commentCountNotification = commentCountNotification {
            commentCountNotification.removeObserver()
            self.commentCountNotification = nil
        }
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        self.href = decoder.decodeKey("href")
        self.token = decoder.decodeKey("token")
        self.contentWarning = decoder.decodeKey("contentWarning")
        self.allowComments = decoder.decodeKey("allowComments")
        self.summary = decoder.decodeKey("summary")
        // optional
        self.content = decoder.decodeOptionalKey("content")
        self.repostContent = decoder.decodeOptionalKey("repostContent")
        self.repostId = decoder.decodeOptionalKey("repostId")
        self.repostPath = decoder.decodeOptionalKey("repostPath")
        self.repostViaId = decoder.decodeOptionalKey("repostViaId")
        self.repostViaPath = decoder.decodeOptionalKey("repostViaPath")
        self.viewsCount = decoder.decodeOptionalKey("viewsCount")
        self.commentsCount = decoder.decodeOptionalKey("commentsCount")
        self.repostsCount = decoder.decodeOptionalKey("repostsCount")
        // links
        self.assets = decoder.decodeOptionalKey("assets")
        super.init(coder: aDecoder)
        // register for updates
        registerNotifications()
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        // active record
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(createdAt, forKey: "createdAt")
        // required
        encoder.encodeObject(href, forKey: "href")
        encoder.encodeObject(token, forKey: "token")
        encoder.encodeObject(contentWarning, forKey: "contentWarning")
        encoder.encodeBool(allowComments, forKey: "allowComments")
        encoder.encodeObject(summary, forKey: "summary")
        // optional
        encoder.encodeObject(content, forKey: "content")
        encoder.encodeObject(repostContent, forKey: "repostContent")
        encoder.encodeObject(repostId, forKey: "repostId")
        encoder.encodeObject(repostPath, forKey: "repostPath")
        encoder.encodeObject(repostViaId, forKey: "repostViaId")
        encoder.encodeObject(repostViaPath, forKey: "repostViaPath")
        if let viewsCount = self.viewsCount {
            encoder.encodeInt64(Int64(viewsCount), forKey: "viewsCount")
        }
        if let commentsCount = self.commentsCount {
            encoder.encodeInt64(Int64(commentsCount), forKey: "commentsCount")
        }
        if let repostsCount = self.repostsCount {
            encoder.encodeInt64(Int64(repostsCount), forKey: "repostsCount")
        }
        // links
        encoder.encodeObject(assets, forKey: "assets")
        super.encodeWithCoder(encoder)
    }

    func save() {
        ElloLinkedStore.sharedInstance.setObject(self, forKey: id, inCollection: MappingType.PostsType.rawValue)
    }

// MARK: JSONAble

    override public class func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        // active record
        let id = json["id"].stringValue
        let createdAt: NSDate = json["created_at"].stringValue.toNSDate()!
        // required
        let href = json["href"].stringValue
        let token = json["token"].stringValue
        let contentWarning = json["content_warning"].stringValue
        let allowComments = json["allow_comments"].boolValue
        let summary: [Regionable] = RegionParser.regions("summary", json: json)
        // create post
        var post = Post(
            id: id,
            createdAt: createdAt,
            href: href,
            token: token,
            contentWarning: contentWarning,
            allowComments: allowComments,
            summary: summary
            )
        // optional
        post.content = RegionParser.regions("content", json: json)
        post.repostContent = RegionParser.regions("repost_content", json: json)
        post.repostId = json["repost_id"].stringValue
        post.repostPath = NSURL(string: json["repost_path"].stringValue)
        post.repostViaId = json["repost_via_id"].stringValue
        post.repostViaPath = NSURL(string: json["repost_via_path"].stringValue)
        post.viewsCount = json["views_count"].int
        post.commentsCount = json["comments_count"].int
        post.repostsCount = json["reposts_count"].int
        // links / nested resources
//        if let linksNode = data["links"] as? [String: AnyObject] {
//            ElloLinkedStore.sharedInstance.parseLinks(linksNode) { links in
//                post.author = links["author"] as? User
//                post.assets = links["assets"] as? [String: Asset]
//                post.comments = links["comments"] as? [Comment]
//            }
//        }

        // links
        post.links = data["links"] as? [String: AnyObject]
        println("fromJSON post \(post.id) links: \(post.links)")
        // store self in collection
        post.save()

        return post
    }
}


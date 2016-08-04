////
///  ElloWebBrowserViewController.swift
//

import KINWebBrowser
import Crashlytics

public class ElloWebBrowserViewController: KINWebBrowserViewController {
    var toolbarHidden = false
    var prevRequestURL: NSURL?
    static var currentUser: User?
    static var elloTabBarController: ElloTabBarController?

    public class func navigationControllerWithBrowser(webBrowser: ElloWebBrowserViewController) -> ElloNavigationController {
        // tell AppDelegate to allow rotation
        AppDelegate.restrictRotation = false
        let xButton = UIBarButtonItem.closeButton(target: webBrowser, action: #selector(ElloWebBrowserViewController.doneButtonPressed(_:)))
        let shareButton = UIBarButtonItem(image: InterfaceImage.Share.normalImage, style: UIBarButtonItemStyle.Plain, target: webBrowser, action: #selector(ElloWebBrowserViewController.shareButtonPressed(_:)))

        webBrowser.navigationItem.leftBarButtonItem = xButton
        webBrowser.navigationItem.rightBarButtonItem = shareButton
        webBrowser.actionButtonHidden = true

        return ElloNavigationController(rootViewController: webBrowser)
    }

    override public class func navigationControllerWithWebBrowser() -> ElloNavigationController {
        let browser = self.init()
        return navigationControllerWithBrowser(browser)
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(toolbarHidden, animated: false)
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .Default
        Crashlytics.sharedInstance().setObjectValue("ElloWebBrowser", forKey: CrashlyticsKey.StreamName.rawValue)
        delegate = self
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    public func shareButtonPressed(sender: AnyObject) {
        var webViewUrl: NSURL?
        if let wkWebView = wkWebView {
            webViewUrl = wkWebView.URL
        }
        else if let uiWebView = uiWebView {
            webViewUrl = uiWebView.request?.URL
        }

        guard let urlForActivityItem = webViewUrl else {
            return
        }

        dispatch_async(dispatch_get_main_queue()) {
            let controller = UIActivityViewController(activityItems: [urlForActivityItem], applicationActivities: [SafariActivity()])
            let actionButton = sender as? UIBarButtonItem
            if let actionButton = actionButton where UI_USER_INTERFACE_IDIOM() == .Pad {
                let actionPopoverController = UIPopoverController(contentViewController: controller)
                actionPopoverController.presentPopoverFromBarButtonItem(actionButton, permittedArrowDirections: .Any, animated: true)
            }
            else {
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }

}

// MARK: ElloWebBrowserViewConteroller: KINWebBrowserDelegate
extension ElloWebBrowserViewController: KINWebBrowserDelegate {

    public func webBrowser(webBrowser: KINWebBrowserViewController!, didFailToLoadURL url: NSURL?, error: NSError!) {
        if let url = url ?? prevRequestURL {
            UIApplication.sharedApplication().openURL(url)
        }
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    public func webBrowser(webBrowser: KINWebBrowserViewController!, shouldStartLoadWithRequest request: NSURLRequest!) -> Bool {
        prevRequestURL = request.URL
        return ElloWebViewHelper.handleRequest(request, webLinkDelegate: self, fromWebView: true)
    }

    public func willDismissWebBrowser(webView: KINWebBrowserViewController) {
        AppDelegate.restrictRotation = true
    }

}

// MARK: ElloWebBrowserViewController : WebLinkDelegate
extension ElloWebBrowserViewController : WebLinkDelegate {
    public func webLinkTapped(type: ElloURI, data: String) {
        switch type {
        case .Confirm,
             .Downloads,
             .Email,
             .External,
             .ForgotMyPassword,
             .FreedomOfSpeech,
             .FaceMaker,
             .Invitations,
             .Join,
             .Login,
             .Manifesto,
             .NativeRedirect,
             .Onboarding,
             .PasswordResetError,
             .ProfileFollowers,
             .ProfileFollowing,
             .ProfileLoves,
             .RandomSearch,
             .RequestInvite,
             .RequestInvitation,
             .RequestInvitations,
             .ResetMyPassword,
             .SearchPeople,
             .SearchPosts,
             .Subdomain,
             .Unblock,
             .WhoMadeThis,
             .WTF:
            break // this is handled in ElloWebViewHelper/KINWebBrowserViewController
        case .Discover,
             .DiscoverRandom,
             .DiscoverRecent,
             .DiscoverRelated,
             .DiscoverTrending,
             .ExploreRecommended,
             .ExploreRecent,
             .ExploreTrending:
            self.selectTab(.Discover)
        case .Category:
            self.selectTab(.Discover)
        case .BetaPublicProfiles,
             .Enter,
             .Exit,
             .Root,
             .Explore:
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        case .Friends,
             .Following,
             .Noise,
             .Starred:
            self.selectTab(.Stream)
        case .Notifications: self.selectTab(.Notifications)
        case .Post,
             .PushNotificationPost,
             .PushNotificationComment:
            self.showPostDetail(data)
        case .Profile,
             .PushNotificationUser:
            self.showProfile(data)
        case .Search: showSearch(data)
        case .Settings: self.showSettings()
        }
    }

    private func showProfile(username: String) {
        let param = "~\(username)"
        if alreadyOnUserProfile(param) { return }
        let vc = ProfileViewController(userParam: param)
        vc.currentUser = ElloWebBrowserViewController.currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showPostDetail(token: String) {
        let param = "~\(token)"
        if alreadyOnPostDetail(param) { return }
        let vc = PostDetailViewController(postParam: param)
        vc.currentUser = ElloWebBrowserViewController.currentUser
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showSearch(terms: String) {
        let vc = SearchViewController()
        vc.currentUser = ElloWebBrowserViewController.currentUser
        vc.searchForPosts(terms)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showSettings() {
        if let settings = UIStoryboard(name: "Settings", bundle: .None).instantiateInitialViewController() as? SettingsContainerViewController {
            settings.currentUser = ElloWebBrowserViewController.currentUser
            navigationController?.pushViewController(settings, animated: true)
        }
    }

    private func selectTab(tab: ElloTab) {
        navigationController?.dismissViewControllerAnimated(true) {
            ElloWebBrowserViewController.elloTabBarController?.selectedTab = tab
        }
    }

    func alreadyOnUserProfile(userParam: String) -> Bool {
        if let profileVC = navigationController?.topViewController as? ProfileViewController {
            return userParam == profileVC.userParam
        }
        return false
    }

    func alreadyOnPostDetail(postParam: String) -> Bool {
        if let postDetailVC = navigationController?.topViewController as? PostDetailViewController {
            return postParam == postDetailVC.postParam
        }
        return false
    }
}

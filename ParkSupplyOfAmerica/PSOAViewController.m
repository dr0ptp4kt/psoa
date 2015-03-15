//
//  PSOAViewController.m
//  ParkSupplyOfAmerica
//
//  Created by a on 8/9/14.
//  Copyright (c) 2014 Park Supply of America. All rights reserved.
//

#import "PSOAViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>



@interface PSOAViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSString* latestUrl;
@property (nonatomic) BOOL hasFirstPageLoaded;
@property NSArray *scaleDownPaths;

@end

@implementation PSOAViewController

- (void)loadPageWith:(NSString *)url
{
    NSURL* u = [NSURL URLWithString:url];
    NSURLRequest *req = [NSURLRequest requestWithURL:u];
    [self.webView loadRequest:req];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.scaleDownPaths = @[@"/Qorderentm.php", @"/cart2m.php", @"/productm.php"];
    NSString *kStartingUrl = @"http://www.parksupplyofamerica.com/mobet.php";
    self.webView.delegate = self;
    UIFont* systemFont = [UIFont systemFontOfSize:12.0];
    NSString *fontName = systemFont.fontName;
    CGFloat buttonfontSize = 24.0;
    NSDictionary *font = @{
                           UITextAttributeFont: [UIFont fontWithName:fontName size:buttonfontSize]
                           };
    [self.backButton setTitleTextAttributes:font forState:UIControlStateNormal];
    [self.forwardButton setTitleTextAttributes:font forState:UIControlStateNormal];
    [self updateNavigability];
    self.latestUrl = kStartingUrl;
    [self loadPageWith:self.latestUrl];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self disableButtons];
    [self.spinner startAnimating];
    return true;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
    self.hasFirstPageLoaded = true;
    self.latestUrl = [webView.request.mainDocumentURL absoluteString];
    [self updateNavigability];
    NSString *currentPath = webView.request.mainDocumentURL.path;
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.setAttribute('style', 'margin:0; padding:0')"];
    
    if ([self.scaleDownPaths containsObject:currentPath]) {
        [webView stringByEvaluatingJavaScriptFromString:@"document.querySelector('meta[name=viewport]\').setAttribute('content', 'width=device-width, initial-scale=0.8, user-scalable=yes')"];
    }
}



-(void)updateNavigability
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

-(void)disableButtons
{
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{

    if (error.code == NSURLErrorCancelled) {
        return; // user likely clicked link of submitted form while loading
    }
    [self complain];
}

-(void)complain
{
    [self.spinner stopAnimating];
    UIAlertView *dialog = [[UIAlertView alloc]
                           initWithTitle: @"Connection Problem"
                           message:@"Please check your internet connection and try again."
                           delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles: self.hasFirstPageLoaded ? @"Okay" : @"Retry"
                           , nil];
    [dialog show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!self.hasFirstPageLoaded) {
        [self loadPageWith:self.latestUrl];
    } else {
        [self updateNavigability];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // well, let's do what we can
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end

//
//  ViewController.m
//  Politisense_2
//
//  Created by Nathan Lintz on 12/13/13.
//  Copyright (c) 2013 Nathan Lintz. All rights reserved.
//

#import "ViewController.h"
#import "Sentiment.h"

@interface ViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *sentimentTextView;
@property (weak, nonatomic) IBOutlet UIButton *sentimentAnalyzeButton;
@property (weak, nonatomic) IBOutlet UILabel *ConservativeLabel;
@property (weak, nonatomic) IBOutlet UILabel *LiberalLabel;
@property (weak, nonatomic) IBOutlet UILabel *LibertarianLabel;
@property (weak, nonatomic) IBOutlet UILabel *GreenLabel;
@property (strong, nonatomic) UIView *conservativeBar;
@property (strong, nonatomic) UIView *liberalBar;
@property (strong, nonatomic) UIView *libertarianBar;
@property (strong, nonatomic) UIView *greenBar;
@property (weak, nonatomic) IBOutlet UILabel *PlaceholderLabel;

- (NSMutableArray *)getSentiment:(NSString *)sentimentString;
- (NSMutableArray *)normalizeSentiments:(NSArray *)rawSentiments;
@end

@implementation ViewController
@synthesize conservativeBar, liberalBar, libertarianBar, greenBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    float yMin = _ConservativeLabel.frame.origin.y;
    float width = self.view.bounds.size.width/4;
    
    self.conservativeBar = [[UIView alloc] initWithFrame:CGRectMake(0, yMin, width, 1.0f)];
    self.liberalBar = [[UIView alloc] initWithFrame:CGRectMake(0 + width, yMin, width, 1.0f)];
    self.libertarianBar = [[UIView alloc] initWithFrame:CGRectMake(0 + 2 * width, yMin, width, 1.0f)];
    self.greenBar = [[UIView alloc] initWithFrame:CGRectMake(0 + 3 * width, yMin, width, 1.0f)];
    
    self.conservativeBar.backgroundColor = [UIColor redColor];
    self.liberalBar.backgroundColor = [UIColor blueColor];
    self.libertarianBar.backgroundColor = [UIColor yellowColor];
    self.greenBar.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:conservativeBar];
    [self.view addSubview:liberalBar];
    [self.view addSubview:libertarianBar];
    [self.view addSubview:greenBar];
    
    [self.sentimentAnalyzeButton  addTarget:self action:@selector(analyzeSentiment:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self.sentimentAnalyzeButton layer] setBorderWidth:1.0f];
    [[self.sentimentAnalyzeButton layer] setCornerRadius:10.0f];
    [[self.sentimentAnalyzeButton layer] setBorderColor:[[UIColor colorWithRed:1.0f green:0.70980392156f blue:0.20392156862f alpha:1.0f] CGColor]];
    _sentimentTextView.delegate = (id)self;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.PlaceholderLabel.text = @"";
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)analyzeSentiment:(id)sender {
    if (![self.sentimentTextView.text isEqualToString: @""])
    {
        
//        float maxHeight = 175.0f;
        float maxHeight = self.view.bounds.size.height / 2.5f;
        float yMin = _ConservativeLabel.frame.origin.y;
    
        NSMutableArray *normalizedSentiments = [self getSentiment:self.sentimentTextView.text];
        CGRect conservativeFrame = self.conservativeBar.frame;
        CGRect liberalFrame = self.liberalBar.frame;
        CGRect libertarianFrame = self.libertarianBar.frame;
        CGRect greenFrame = self.greenBar.frame;
    
        conservativeFrame.size.height = maxHeight * [[normalizedSentiments objectAtIndex:0] floatValue];
        liberalFrame.size.height = maxHeight * [[normalizedSentiments objectAtIndex:1] floatValue];
        libertarianFrame.size.height = maxHeight * [[normalizedSentiments objectAtIndex:2] floatValue];
        greenFrame.size.height = maxHeight * [[normalizedSentiments objectAtIndex:3] floatValue];
        
        conservativeFrame.origin.y = yMin - conservativeFrame.size.height;
        liberalFrame.origin.y = yMin - liberalFrame.size.height;
        libertarianFrame.origin.y = yMin - libertarianFrame.size.height;
        greenFrame.origin.y = yMin - greenFrame.size.height;
    
        self.conservativeBar.frame = conservativeFrame;
        self.liberalBar.frame = liberalFrame;
        self.libertarianBar.frame = libertarianFrame;
        self.greenBar.frame = greenFrame;
    }
    [self.sentimentTextView resignFirstResponder];
}

- (NSMutableArray *)getSentiment:(NSString *)sentimentString
{
    Sentiment *sentimentClient = [[Sentiment alloc] init];
    NSDictionary *sentimentDict = [sentimentClient getSentiment:sentimentString];
    
    CGFloat conservativeSentiment = [[sentimentDict objectForKey:@"Conservative"] floatValue];
    CGFloat liberalSentiment = [[sentimentDict objectForKey:@"Liberal"] floatValue];
    CGFloat libertarianSentiment = [[sentimentDict objectForKey:@"Libertarian"] floatValue];
    CGFloat greenSentiment = [[sentimentDict objectForKey:@"Green"] floatValue];

    NSArray *sentiments = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:conservativeSentiment],
                           [NSNumber numberWithFloat:liberalSentiment],
                           [NSNumber numberWithFloat:libertarianSentiment],
                           [NSNumber numberWithFloat:greenSentiment],
                           nil];
    NSMutableArray *normalizedSentiments = [self normalizeSentiments:sentiments];
    return normalizedSentiments;
}

- (NSMutableArray *)normalizeSentiments:(NSArray *)rawSentiments
{
    NSMutableArray *normalizedSentiments = [[NSMutableArray alloc] init];
    float max = [[rawSentiments valueForKeyPath:@"@max.floatValue"] floatValue];
    float min = [[rawSentiments valueForKeyPath:@"@min.floatValue"] floatValue];
    float normalizingConstant = .1 * (max - min);
    
    for (NSNumber *sentiment in rawSentiments)
    {
        float sentimentValue = [sentiment floatValue];
        float normalizedSentimentValue = (sentimentValue - min + normalizingConstant)/(max - min + normalizingConstant);
        [normalizedSentiments addObject:[NSNumber numberWithFloat:normalizedSentimentValue]];
    }
    return normalizedSentiments;
}

@end

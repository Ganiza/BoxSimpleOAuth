#import <SimpleOAuth2/SimpleOAuth2.h>
#import "BoxAuthenticationManager.h"
#import "BoxLoginResponse.h"
#import "BoxConstants.h"
#import "BoxTokenParameters.h"


NSString *const BoxTokenEndpoint = @"/api/oauth2/token";

@interface BoxAuthenticationManager ()

@property (copy, nonatomic) NSString *clientID;
@property (copy, nonatomic) NSString *clientSecret;
@property (copy, nonatomic) NSString *callbackURLString;
@property (strong, nonatomic) SimpleOAuth2AuthenticationManager *simpleOAuth2AuthenticationManager;

@end

@implementation BoxAuthenticationManager

#pragma mark - Init Methods

- (instancetype)initWithClientID:(NSString *)clientID
                    clientSecret:(NSString *)clientSecret
               callbackURLString:(NSString *)callbackURLString
{
    self = [super init];
    if (self) {
        self.clientID = clientID;
        self.clientSecret = clientSecret;
        self.callbackURLString = callbackURLString;
        self.simpleOAuth2AuthenticationManager = [[SimpleOAuth2AuthenticationManager alloc] init];
    }
    return self;
}

#pragma mark - Public Methods

- (void)authenticateClientWithAuthCode:(NSString *)authCode
                               success:(void (^)(BoxLoginResponse *reponse))success
                               failure:(void (^)(NSError *error))failure
{
    NSString *authenticationURLString = [NSString stringWithFormat:@"%@%@", BoxAuthURL, BoxTokenEndpoint];
    
    [self.simpleOAuth2AuthenticationManager authenticateOAuthClient:[NSURL URLWithString:authenticationURLString]
                                                    tokenParameters:[self boxTokenParametersFromAuthCode:authCode]
                                                            success:^(id authResponseObject) {
                                                                BoxLoginResponse *loginResponse = [[BoxLoginResponse alloc] initWithBoxOAuthResponse:authResponseObject];
                                                                success(loginResponse);
                                                            } failure:failure];
}

#pragma mark - Private Methods

- (id<TokenParameters>)boxTokenParametersFromAuthCode:(NSString *)authCode
{
    BoxTokenParameters *boxTokenParameters = [[BoxTokenParameters alloc] init];
    boxTokenParameters.clientID = self.clientID;
    boxTokenParameters.clientSecret = self.clientSecret;
    boxTokenParameters.callbackURLString = self.callbackURLString;
    boxTokenParameters.authorizationCode = authCode;
    
    return boxTokenParameters;
}

@end

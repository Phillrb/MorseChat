//
//  PRBAboutViewController.m
//  MorseChat
//
//  Created by Phillip Riscombe-Burton on 05/10/2014.
//  Copyright (c) 2014 Phillip Riscombe-Burton. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "PRBAboutViewController.h"
#import "PRBPreviewViewController.h"
#import "Appirater.h"
#import "Flurry.h"

@interface PRBAboutViewController ()

@property(nonatomic, assign) IBOutlet UIButton *rateButton;
@property(nonatomic, assign) IBOutlet UIButton *flashButton;

@property(nonatomic, assign) IBOutlet UIScrollView *scroll;
@property(nonatomic, assign) IBOutlet UITextView *infoTextView;

@end

@implementation PRBAboutViewController

#define kTorchSetting @"torchSetting"

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Update light setting
    [self updateTorchButtonTitle];
    
    //Add all that text and resize everything!
    [self updateAboutText];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
       
        [self updateAboutText];
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)goBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)rateTapped:(id)sender
{
    [Flurry logEvent:@"Rate"];
    [Appirater rateApp];
}

-(IBAction)torchSettingTapped:(id)sender
{
    //Toggle torch button
    BOOL canUseTorch = [PRBAboutViewController canUseTorch];
    [PRBAboutViewController setTorchSetting:!canUseTorch];
    
    if(!canUseTorch) [Flurry logEvent:@"Torch on"];
    else [Flurry logEvent:@"Torch off"];
    
    [self updateTorchButtonTitle];
}

-(void)updateTorchButtonTitle{
    
    BOOL canUseTorch = [PRBAboutViewController canUseTorch];
    if (canUseTorch) {
        [_flashButton setTitle:@"Flashlight on" forState:UIControlStateNormal];
    }
    else
    {
        [_flashButton setTitle:@"Flashlight off" forState:UIControlStateNormal];
    }
}

#pragma mark - printables
-(IBAction)resourcesTapped:(id)sender{
    
    PRBPreviewViewController * previewController = [[PRBPreviewViewController alloc] init];
    [previewController setDelegate:previewController];
    [previewController setDataSource:previewController];
    [self presentViewController:previewController animated:YES completion:nil];
    
}

#pragma mark - settings

//Torch
+(BOOL)canUseTorch{
    return [PRBAboutViewController getTorchSetting];
}

+(BOOL)getTorchSetting{
    return [PRBAboutViewController getBoolSettingWithKey:kTorchSetting defaultsTo:NO];
}

+(void)setTorchSetting:(BOOL)newValue{
    [PRBAboutViewController setBoolSettingWithKey:kTorchSetting toNewValue:newValue];
 }

+(BOOL)getBoolSettingWithKey:(NSString*)key defaultsTo:(BOOL)defaultValue{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![defaults objectForKey:key])
    {
        [defaults setBool:defaultValue forKey:key];
        [defaults synchronize];
    }
    
    return [defaults boolForKey:key];
    
}

+(void)setBoolSettingWithKey:(NSString*)key toNewValue:(BOOL)newValue{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:newValue forKey:key];
    [defaults synchronize];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}


-(void)updateAboutText{
    
    float adjust = self.view.frame.size.width > 400 ? 7.0f : 0.0f;
    
    float yPos = _rateButton.frame.origin.y + _rateButton.frame.size.height + 18.0f;
    [_infoTextView setFrame:CGRectMake(0.0f, yPos, self.view.frame.size.width - adjust, 0.0f)];
    
    [_infoTextView setText:@"This app uses the following open source projects:\n\
     - ITProgressBar by Ilija Tovilo\n\
     - Appirater by Arash Payan\
     \n\n\
     \nAn excerpt taken from the Wikipedia entry for 'Morse Code':\
     \nhttp://en.wikipedia.org/wiki/Morse_code\
     \n\
     \nMorse code is a method of transmitting text information as a series of on-off tones, lights, or clicks that can be directly understood by a skilled listener or observer without special equipment. The International Morse Code encodes the ISO basic Latin alphabet, some extra Latin letters, the Arabic numerals and a small set of punctuation and procedural signals as standardized sequences of short and long signals called \"dots\" and \"dashes\", or \"dits\" and \"dahs\". Because many non-English natural languages use more than the 26 Roman letters, extensions to the Morse alphabet exist for those languages.\n\
     \nEach character (letter or numeral) is represented by a unique sequence of dots and dashes. The duration of a dash is three times the duration of a dot. Each dot or dash is followed by a short silence, equal to the dot duration. The letters of a word are separated by a space equal to three dots (one dash), and the words are separated by a space equal to seven dots. The dot duration is the basic unit of time measurement in code transmission. For efficiency, the length of each character in Morse is approximately inversely proportional to its frequency of occurrence in English. Thus, the most common letter in English, the letter \"E,\" has the shortest code, a single dot.\n\
     \nMorse code is most popular among amateur radio operators, although it is no longer required for licensing in most countries. Pilots and air traffic controllers usually need only a cursory understanding. Aeronautical navigational aids, such as VORs and NDBs, constantly identify in Morse code. Compared to voice, Morse code is less sensitive to poor signal conditions, yet still comprehensible to humans without a decoding device. Morse is therefore a useful alternative to synthesized speech for sending automated data to skilled listeners on voice channels. Many amateur radio repeaters, for example, identify with Morse, even though they are used for voice communications.\n\
     \nFor emergency signals, Morse code can be sent by way of improvised sources that can be easily \"keyed\" on and off, making it one of the simplest and most versatile methods of telecommunication. The most common distress signal is SOS or three dots, three dashes and three dots, internationally recognized by treaty.\n\
     \n\
     \nDevelopment and history\n\
     \nBeginning in 1836, the American artist Samuel F. B. Morse, the American physicist Joseph Henry, and Alfred Vail developed an electrical telegraph system. This system sent pulses of electric current along wires which controlled an electromagnet that was located at the receiving end of the telegraph system. A code was needed to transmit natural language using only these pulses, and the silence between them. Morse therefore developed the forerunner to modern International Morse code.\n\
     \nIn 1837, William Cooke and Charles Wheatstone in England began using an electrical telegraph that also used electromagnets in its receivers. However, in contrast with any system of making sounds of clicks, their system used pointing needles that rotated above alphabetical charts to indicate the letters that were being sent. In 1841, Cooke and Wheatstone built a telegraph that printed the letters from a wheel of typefaces struck by a hammer. This machine was based on their 1840 telegraph and worked well; however, they failed to find customers for this system and only two examples were ever built.\n\
     \nOn the other hand, the three Americans' system for telegraphy, which was first used in about 1844, was designed to make indentations on a paper tape when electric currents were received. Morse's original telegraph receiver used a mechanical clockwork to move a paper tape. When an electrical current was received, an electromagnet engaged an armature that pushed a stylus onto the moving paper tape, making an indentation on the tape. When the current was interrupted, a spring retracted the stylus, and that portion of the moving tape remained unmarked.\n\
     \nThe Morse code was developed so that operators could translate the indentations marked on the paper tape into text messages. In his earliest code, Morse had planned to only transmit numerals, and use a dictionary to look up each word according to the number which had been sent. However, the code was soon expanded by Alfred Vail to include letters and special characters, so it could be used more generally. Vail determined the frequency of use of letters in the English language by counting the movable type he found in the type-cases of a local newspaper in Morristown. The shorter marks were called \"dots\", and the longer ones \"dashes\", and the letters most commonly used were assigned the shorter sequences of dots and dashes.\n\
     \nIn the original Morse telegraphs, the receiver's armature made a clicking noise as it moved in and out of position to mark the paper tape. The telegraph operators soon learned that they could translate the clicks directly into dots and dashes, and write these down by hand, thus making the paper tape unnecessary. When Morse code was adapted to radio communication, the dots and dashes were sent as short and long pulses. It was later found that people became more proficient at receiving Morse code when it is taught as a language that is heard, instead of one read from a page.\n\
     \nTo reflect the sounds of Morse code receivers, the operators began to vocalize a dot as \"dit\", and a dash as \"dah\". Dots which are not the final element of a character became vocalized as \"di\". For example, the letter \"c\" was then vocalized as \"dah-di-dah-dit\".\n\
     \nIn the 1890s, Morse code began to be used extensively for early radio communication, before it was possible to transmit voice. In the late nineteenth and early twentieth century, most high-speed international communication used Morse code on telegraph lines, undersea cables and radio circuits. In aviation, Morse code in radio systems started to be used on a regular basis in the 1920s. Although previous transmitters were bulky and the spark gap system of transmission was difficult to use, there had been some earlier attempts. In 1910 the U.S. Navy experimented with sending Morse from an airplane. That same year a radio on the airship America had been instrumental in coordinating the rescue of its crew. Zeppelin airships equipped with radio were used for bombing and naval scouting during World War I, and ground-based radio direction finders were used for airship navigation. Allied airships and military aircraft also made some use of radiotelegraphy. However, there was little aeronautical radio in general use during World War I, and in the 1920s there was no radio system used by such important flights as that of Charles Lindbergh from New York to Paris in 1927. Once he and the Spirit of St. Louis were off the ground, Lindbergh was truly alone and incommunicado. On the other hand, when the first airplane flight was made from California to Australia in the 1930s on the Southern Cross, one of its four crewmen was its radio operator who communicated with ground stations via radio telegraph.\n\
     \nBeginning in the 1930s, both civilian and military pilots were required to be able to use Morse code, both for use with early communications systems and identification of navigational beacons which transmitted continuous two- or three-letter identifiers in Morse code. Aeronautical charts show the identifier of each navigational aid next to its location on the map.\n\
     \nRadio telegraphy using Morse code was vital during World War II, especially in carrying messages between the warships and the naval bases of the belligerents. Long-range ship-to-ship communications was by radio telegraphy, using encrypted messages, because the voice radio systems on ships then were quite limited in both their range, and their security. Radiotelegraphy was also extensively used by warplanes, especially by long-range patrol planes that were sent out by these navies to scout for enemy warships, cargo ships, and troop ships.\n\
     \nIn addition, rapidly moving armies in the field could not have fought effectively without radiotelegraphy, because they moved more rapidly than telegraph and telephone lines could be erected. This was seen especially in the blitzkrieg offensives of the Nazi German Wehrmacht in Poland, Belgium, France (in 1940), the Soviet Union, and in North Africa; by the British Army in North Africa, Italy, and the Netherlands; and by the U.S. Army in France and Belgium (in 1944), and in southern Germany in 1945.\n\
     \nMorse code was used as an international standard for maritime distress until 1999, when it was replaced by the Global Maritime Distress Safety System. When the French Navy ceased using Morse code on January 31, 1997, the final message transmitted was \"Calling all. This is our last cry before our eternal silence.\" In the United States the final commercial Morse code transmission was on July 12, 1999, signing off with Samuel Morse's original 1844 message, \"What hath God wrought\", and the prosign \"SK\".\n\
     \nThe United States Coast Guard has ceased all use of Morse code on the radio, and no longer monitors any radio frequencies for Morse code transmissions, including the international medium frequency (MF) distress frequency of 500 kHz. However the Federal Communications Commission still grants commercial radiotelegraph operator licenses to applicants who pass its code and written tests. Licensees have reactivated the old California coastal Morse station KPH and regularly transmit from the site under either this Call sign or as KSM. Similarly, a few US Museum ship stations are operated by Morse enthusiasts.\n\
     \n\
     \nUser proficiency\n\
     \nMorse code speed is measured in words per minute (wpm) or characters per minute (cpm). Characters have differing lengths because they contain differing numbers of dots and dashes. Consequently words also have different lengths in terms of dot duration, even when they contain the same number of characters. For this reason, a standard word is helpful to measure operator transmission speed. \"PARIS\" and \"CODEX\" are two such standard words. Operators skilled in Morse code can often understand (\"copy\") code in their heads at rates in excess of 40 wpm.\n\
     \nInternational contests in code copying are still occasionally held. In July 1939 at a contest in Asheville, North Carolina in the United States Ted R. McElroy set a still-standing record for Morse copying, 75.2 wpm. William Pierpont N0HFF also notes that some operators may have passed 100 wpm. By this time they are \"hearing\" phrases and sentences rather than words. The fastest speed ever sent by a straight key was achieved in 1942 by Harry Turner W9YZE (d. 1992) who reached 35 wpm in a demonstration at a U.S. Army base. To accurately compare code copying speed records of different eras it is useful to keep in mind that different standard words (50 dot durations versus 60 dot durations) and different interword gaps (5 dot durations versus 7 dot durations) may have been used when determining such speed records. For example speeds run with the CODEX standard word and the PARIS standard may differ by up to 20%.\n\
     \nToday among amateur operators there are several organizations that recognize high speed code ability, one group consisting of those who can copy Morse at 60 wpm. Also, Certificates of Code Proficiency are issued by several amateur radio societies, including the American Radio Relay League. Their basic award starts at 10 wpm with endorsements as high as 40 wpm, and are available to anyone who can copy the transmitted text. Members of the Boy Scouts of America may put a Morse interpreter's strip on their uniforms if they meet the standards for translating code at 5 wpm.\n\
     \n\
     \nInternational Morse Code\n\
     \nMorse code has been in use for more than 160 years—longer than any other electrical coding system. What is called Morse code today is actually somewhat different from what was originally developed by Vail and Morse. The Modern International Morse code, or continental code, was created by Friedrich Clemens Gerke in 1848 and initially used for telegraphy between Hamburg and Cuxhaven in Germany. Gerke changed nearly half of the alphabet and all of the numerals resulting substantially in the modern form of the code. After some minor changes, International Morse Code was standardized at the International Telegraphy Congress in 1865 in Paris, and was later made the standard by the International Telecommunication Union (ITU). Morse's original code specification, largely limited to use in the United States and Canada, became known as American Morse code or railroad code. American Morse code is now seldom used except in historical re-enactments.\n\
     \n\nAviation\n\
     \nIn aviation, instrument pilots use radio navigation aids. To ensure that the stations the pilots are using are serviceable, the stations all transmit a short set of identification letters (usually a two-to-five-letter version of the station name) in Morse code. Station identification letters are shown on air navigation charts. For example, the VOR based at Manchester Airport in England is abbreviated as \"MCT\", and MCT in Morse code is transmitted on its radio frequency. In some countries, during periods of maintenance, the facility may radiate a T-E-S-T code (—  ·  · · ·  —) or the code may be removed, which tells pilots and navigators that the station is unreliable. In Canada, the identification is removed entirely to signify the navigation aid is not to be used. In the aviation service Morse is typically sent at a very slow speed of about 5 words per minute. In the U.S., pilots do not actually have to know Morse to identify the transmitter because the dot/dash sequence is written out next to the transmitter's symbol on aeronautical charts. Some modern navigation receivers automatically translate the code into displayed letters.\n\
     \n\
     \nAmateur radio\
     \n\
     \nInternational Morse code today is most popular among amateur radio operators, where it is used as the pattern to key a transmitter on and off in the radio communications mode commonly referred to as \"continuous wave\" or \"CW\" to distinguish it from spark transmissions, not because the transmission was continuous. Other keying methods are available in radio telegraphy, such as frequency shift keying.\n\
     \nThe original amateur radio operators used Morse code exclusively, since voice-capable radio transmitters did not become commonly available until around 1920. Until 2003 the International Telecommunication Union mandated Morse code proficiency as part of the amateur radio licensing procedure worldwide. However, the World Radiocommunication Conference of 2003 made the Morse code requirement for amateur radio licensing optional. Many countries subsequently removed the Morse requirement from their licence requirements.\n\
     \nUntil 1991 a demonstration of the ability to send and receive Morse code at a minimum of five words per minute (wpm) was required to receive an amateur radio license for use in the United States from the Federal Communications Commission. Demonstration of this ability was still required for the privilege to use the HF bands. Until 2000 proficiency at the 20 wpm level was required to receive the highest level of amateur license (Amateur Extra Class); effective April 15, 2000, the FCC reduced the Extra Class requirement to five wpm. Finally, effective on February 23, 2007 the FCC eliminated the Morse code proficiency requirements from all amateur radio licenses.\n\
     \nWhile voice and data transmissions are limited to specific amateur radio bands under U.S. rules, Morse code is permitted on all amateur bands—LF, MF, HF, UHF, and VHF. In some countries, certain portions of the amateur radio bands are reserved for transmission of Morse code signals only.\n\
     \nThe relatively limited speed at which Morse code can be sent led to the development of an extensive number of abbreviations to speed communication. These include prosigns, Q codes, and a set of Morse code abbreviations for typical message components. For example, CQ is broadcast to be interpreted as \"seek you\" (I'd like to converse with anyone who can hear my signal). OM (old man), YL (young lady) and XYL (\"ex-YL\" – wife) are common abbreviations. YL or OM is used by an operator when referring to the other operator, XYL or OM is used by an operator when referring to his or her spouse. QTH is \"location\" (\"My QTH\" is \"My location\"). The use of abbreviations for common terms permits conversation even when the operators speak different languages.\n\
     \nAlthough the traditional telegraph key (straight key) is still used by some amateurs, the use of mechanical semi-automatic keyers (known as \"bugs\") and of fully automatic electronic keyers is prevalent today. Software is also frequently employed to produce and decode Morse code radio signals.\n\
     \n\
     \nOther uses\n\
     \nThrough May 2013 the First, Second, and Third Class (commercial) Radiotelegraph Licenses using code tests based upon the CODEX standard word were still being issued in the United States by the Federal Communications Commission. The First Class license required 20 WPM code group and 25 WPM text code proficiency, the others 16 WPM code group test (five letter blocks sent as simulation of receiving encrypted text) and 20 WPM code text (plain language) test. It was also necessary to pass written tests on operating practice and electronics theory. A unique additional demand for the First Class was a requirement of a year of experience for operators of shipboard and coast stations using Morse. This allowed the holder to be chief operator on board a passenger ship. However, since 1999 the use of satellite and very high frequency maritime communications systems (GMDSS) has made them obsolete. (By that point meeting experience requirement for the First was very difficult.) Currently only one class of license, the Radiotelegraph Operator Certificate, is issued. This is granted either when the tests are passed or as the Second and First are renewed and become this lifetime license. For new applicants it requires passing a written examination on electronic theory, as well as 16 WPM code and 20 WPM text tests. However the code exams are currently waived for holders of Amateur Extra Class licenses who obtained their operating privileges under the old 20 WPM test requirement.\n\
     \nRadio navigation aids such as VORs and NDBs for aeronautical use broadcast identifying information in the form of Morse Code, though many VOR stations now also provide voice identification. Warships, including those of the U.S. Navy, have long used signal lamps to exchange messages in Morse code. Modern use continues, in part, as a way to communicate while maintaining radio silence. Submarine periscopes include a signal lamp.\n\n\
     \nApplications for the general public\n\
     \nAn important application is signalling for help through SOS, \"· · · — — — · · ·\". This can be sent many ways: keying a radio on and off, flashing a mirror, toggling a flashlight and similar methods. SOS is not three separate characters, rather, it is a prosign SOS, and is keyed without gaps between characters.\n\n\
     \nMorse code as an assistive technology\n\
     \nMorse code has been employed as an assistive technology, helping people with a variety of disabilities to communicate. Morse can be sent by persons with severe motion disabilities, as long as they have some minimal motor control. An original solution to the problem that caretakers have to learn to decode has been an electronic typewriter with the codes written on the keys. Codes were sung by users; see the voice typewriter employing morse or votem, Newell and Nabarro, 1968.\n\
     \nMorse code can also be translated by computer and used in a speaking communication aid. In some cases this means alternately blowing into and sucking on a plastic tube (\"sip-and-puff\" interface). An important advantage of Morse code over row column scanning is that, once learned, it does not require looking at a display. Also, it appears faster than scanning.\n\
     \nPeople with severe motion disabilities in addition to sensory disabilities (e.g. people who are also deaf or blind) can receive Morse through a skin buzzer.[citation needed].\n\
     \nIn one case reported in the radio amateur magazine QST, an old shipboard radio operator who had a stroke and lost the ability to speak or write could communicate with his physician (a radio amateur) by blinking his eyes in Morse. Another example occurred in 1966 when prisoner of war Jeremiah Denton, brought on television by his North Vietnamese captors, Morse-blinked the word TORTURE. In these two cases interpreters were available to understand those series of eye-blinks."
     ];
    
    [_infoTextView sizeToFit];
    [_infoTextView layoutIfNeeded];

    [_scroll setContentSize:CGSizeMake(_scroll.contentSize.width, _infoTextView.frame.origin.y + _infoTextView.frame.size.height)];

}


@end

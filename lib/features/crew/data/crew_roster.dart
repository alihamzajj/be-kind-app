import 'package:flutter/material.dart';

import '../models/crew_models.dart';

/// The Kindness Crew. Art is drawn on a 64x64 canvas; colours are uppercase
/// hex so shiny and silhouette versions can swap them.
const List<CrewCharacter> kCrew = [
  CrewCharacter(
    id: 'momo',
    name: 'Momo',
    species: 'cat',
    title: 'the thank-you expert',
    kind: 'Gratitude',
    rarity: Rarity.common,
    bio:
        'Momo keeps a tiny notebook of every nice thing anyone has ever done '
        'for her, and tries to say thank you for all of them.',
    lines: [
      'Psst. Who made you smile this week? Tell them.',
      'A thank-you note takes two minutes and lasts all day.',
      'I wrote your name in my notebook. Good things only.',
    ],
    doneLine: 'You did it! That goes straight in my notebook.',
    unlockHint: 'Your first friend',
    tint: Color(0xFFFFF1DA),
    art: CharacterArt(
      back:
          '<path d="M14 24 L17 6 L29 18 Z" fill="#EF9F27"/>'
          '<path d="M50 24 L47 6 L35 18 Z" fill="#EF9F27"/>'
          '<path d="M17.5 19 L18.5 11 L24 16.5 Z" fill="#F4C0D1"/>'
          '<path d="M46.5 19 L45.5 11 L40 16.5 Z" fill="#F4C0D1"/>',
      body:
          '<circle cx="32" cy="36" r="22" fill="#FAC775"/>'
          '<ellipse cx="32" cy="47" rx="10" ry="7" fill="#FDE7C2"/>',
      eyes:
          '<circle cx="24" cy="34" r="3.2" fill="#412402"/>'
          '<circle cx="40" cy="34" r="3.2" fill="#412402"/>'
          '<circle cx="25.2" cy="32.8" r="1.1" fill="#FFFFFF"/>'
          '<circle cx="41.2" cy="32.8" r="1.1" fill="#FFFFFF"/>',
      blink:
          '<path d="M20.5 34.5 Q24 37 27.5 34.5 M36.5 34.5 Q40 37 43.5 34.5" '
          'stroke="#412402" stroke-width="2" fill="none" stroke-linecap="round"/>',
      face:
          '<ellipse cx="18.5" cy="41" rx="4" ry="2.5" fill="#F0997B"/>'
          '<ellipse cx="45.5" cy="41" rx="4" ry="2.5" fill="#F0997B"/>'
          '<path d="M29 40 Q30.5 42 32 40 Q33.5 42 35 40" stroke="#412402" '
          'stroke-width="1.8" fill="none" stroke-linecap="round"/>'
          '<path d="M7 38 H16 M7 43 H16 M48 38 H57 M48 43 H57" stroke="#854F0B" '
          'stroke-width="1.2" stroke-linecap="round"/>',
      top:
          '<path d="M32 13 C30 10 26 11 27 14 C28 16 32 18.5 32 18.5 '
          'C32 18.5 36 16 37 14 C38 11 34 10 32 13Z" fill="#E24B4A"/>',
    ),
    shinyColors: {
      '#FAC775': '#D8D4FA',
      '#EF9F27': '#9C93E6',
      '#FDE7C2': '#F1EFFE',
      '#F0997B': '#F4A8C8',
    },
  ),
  CrewCharacter(
    id: 'pip',
    name: 'Pip',
    species: 'penguin',
    title: 'the neighbourhood helper',
    kind: 'Community',
    rarity: Rarity.common,
    bio:
        'Pip knows every shopkeeper on the street by name and waddles over '
        'to help whenever someone drops their groceries.',
    lines: [
      'Say hi to someone at the shop today. Watch them light up.',
      'Small towns are built from small kindnesses.',
      'Waddle out there and make the street a little warmer.',
    ],
    doneLine: 'The whole street feels warmer now. Nice work!',
    unlockHint: 'Hatch from an egg',
    tint: Color(0xFFE9EEF6),
    art: CharacterArt(
      back:
          '<ellipse cx="11" cy="42" rx="5" ry="10" fill="#2C2C2A" transform="rotate(20 11 42)"/>'
          '<ellipse cx="53" cy="42" rx="5" ry="10" fill="#2C2C2A" transform="rotate(-20 53 42)"/>'
          '<ellipse cx="25" cy="60" rx="5" ry="2.5" fill="#EF9F27"/>'
          '<ellipse cx="39" cy="60" rx="5" ry="2.5" fill="#EF9F27"/>',
      body:
          '<ellipse cx="32" cy="37" rx="21" ry="23" fill="#2C2C2A"/>'
          '<ellipse cx="32" cy="42" rx="14" ry="16.5" fill="#F1EFE8"/>',
      eyes:
          '<circle cx="25" cy="28" r="3.4" fill="#FFFFFF"/>'
          '<circle cx="39" cy="28" r="3.4" fill="#FFFFFF"/>'
          '<circle cx="25.6" cy="28.4" r="1.8" fill="#2C2C2A"/>'
          '<circle cx="39.6" cy="28.4" r="1.8" fill="#2C2C2A"/>',
      blink:
          '<path d="M21.5 28.5 Q25 31 28.5 28.5 M35.5 28.5 Q39 31 42.5 28.5" '
          'stroke="#F1EFE8" stroke-width="2" fill="none" stroke-linecap="round"/>',
      face:
          '<path d="M28 33 L36 33 L32 38 Z" fill="#EF9F27"/>'
          '<ellipse cx="21" cy="36" rx="3" ry="2" fill="#F4C0D1"/>'
          '<ellipse cx="43" cy="36" rx="3" ry="2" fill="#F4C0D1"/>',
      top:
          '<path d="M18 18 Q32 1 46 18 Z" fill="#E24B4A"/>'
          '<rect x="17" y="15.5" width="30" height="5" rx="2.5" fill="#A32D2D"/>'
          '<circle cx="32" cy="5" r="3" fill="#F1EFE8"/>',
    ),
    shinyColors: {
      '#2C2C2A': '#1F3B66',
      '#E24B4A': '#EF9F27',
      '#A32D2D': '#BA7517',
    },
  ),
  CrewCharacter(
    id: 'fern',
    name: 'Fern',
    species: 'fox',
    title: 'the nature guardian',
    kind: 'Environment',
    rarity: Rarity.common,
    bio:
        'Fern wears a leaf she rescued from a puddle. She picks up one piece '
        'of litter on every walk and calls it her daily treasure.',
    lines: [
      'One piece of litter picked up is one less for the birds.',
      'Trees can\'t say thank you, so I say it for them.',
      'Bring a reusable cup today. The planet will notice.',
    ],
    doneLine: 'The trees are cheering. I can hear them!',
    unlockHint: 'Hatch from an egg',
    tint: Color(0xFFFCEDE6),
    art: CharacterArt(
      back: '<path d="M12 26 L15 6 L28 19 Z M52 26 L49 6 L36 19 Z" fill="#D85A30"/>',
      body:
          '<circle cx="32" cy="37" r="21" fill="#F0997B"/>'
          '<path d="M13 40 Q32 66 51 40 Q43 52 32 52 Q21 52 13 40Z" fill="#FAECE7"/>',
      eyes:
          '<circle cx="25" cy="34" r="2.9" fill="#4A1B0C"/>'
          '<circle cx="39" cy="34" r="2.9" fill="#4A1B0C"/>'
          '<circle cx="26" cy="33" r="1" fill="#FFFFFF"/>'
          '<circle cx="40" cy="33" r="1" fill="#FFFFFF"/>',
      blink:
          '<path d="M21.8 34.5 Q25 37 28.2 34.5 M35.8 34.5 Q39 37 42.2 34.5" '
          'stroke="#4A1B0C" stroke-width="2" fill="none" stroke-linecap="round"/>',
      face:
          '<circle cx="32" cy="43" r="2.4" fill="#4A1B0C"/>'
          '<path d="M29 46 Q32 48.5 35 46" stroke="#4A1B0C" stroke-width="1.6" '
          'fill="none" stroke-linecap="round"/>'
          '<ellipse cx="19" cy="41" rx="3" ry="2" fill="#F4C0D1"/>'
          '<ellipse cx="45" cy="41" rx="3" ry="2" fill="#F4C0D1"/>',
      top:
          '<path d="M30 3 Q40 5 37 16 Q28 12 30 3Z" fill="#639922"/>'
          '<path d="M32 6 L35 14" stroke="#27500A" stroke-width="1"/>',
    ),
    shinyColors: {
      '#F0997B': '#B5D4F4',
      '#D85A30': '#378ADD',
      '#FAECE7': '#F7FBFF',
    },
  ),
  CrewCharacter(
    id: 'bolt',
    name: 'Bolt',
    species: 'puppy',
    title: 'always ready to help',
    kind: 'Helping someone',
    rarity: Rarity.common,
    bio:
        'Bolt runs so fast to help that he once arrived before anyone asked. '
        'He has carried 312 shopping bags and counting.',
    lines: [
      'Hold a door today. Bonus points if they have coffee.',
      'Need a hand? I have four paws. Let\'s go!',
      'Helping is my favourite sport.',
    ],
    doneLine: 'Woof! That was a perfect help. High paw!',
    unlockHint: 'Hatch from an egg',
    tint: Color(0xFFFBEDE7),
    art: CharacterArt(
      back:
          '<ellipse cx="13" cy="34" rx="7" ry="13" fill="#993C1D" transform="rotate(15 13 34)"/>'
          '<ellipse cx="51" cy="34" rx="7" ry="13" fill="#993C1D" transform="rotate(-15 51 34)"/>',
      body:
          '<circle cx="32" cy="36" r="21" fill="#F5C4B3"/>'
          '<ellipse cx="40" cy="31" rx="7" ry="6" fill="#F0997B"/>',
      eyes:
          '<circle cx="25" cy="32" r="3" fill="#4A1B0C"/>'
          '<circle cx="39" cy="32" r="3" fill="#4A1B0C"/>'
          '<circle cx="26" cy="31" r="1" fill="#FFFFFF"/>'
          '<circle cx="40" cy="31" r="1" fill="#FFFFFF"/>',
      blink:
          '<path d="M21.8 32.5 Q25 35 28.2 32.5 M35.8 32.5 Q39 35 42.2 32.5" '
          'stroke="#4A1B0C" stroke-width="2" fill="none" stroke-linecap="round"/>',
      face:
          '<ellipse cx="32" cy="40" rx="4" ry="3" fill="#4A1B0C"/>'
          '<path d="M28 44 Q32 47 36 44" stroke="#4A1B0C" stroke-width="1.6" '
          'fill="none" stroke-linecap="round"/>'
          '<path d="M30.2 45.5 Q32 52 33.8 45.5Z" fill="#E24B4A"/>',
      top: '<path d="M24 5 L19.5 14 H25 L22 22.5 L31 11 H26 L29.5 5Z" fill="#EF9F27"/>',
    ),
    shinyColors: {
      '#F5C4B3': '#F1EFE8',
      '#F0997B': '#B4B2A9',
      '#993C1D': '#2C2C2A',
    },
  ),
  CrewCharacter(
    id: 'mochi',
    name: 'Mochi',
    species: 'panda',
    title: 'the champion hugger',
    kind: 'Family & Friends',
    rarity: Rarity.common,
    bio:
        'Mochi has never met a hug she didn\'t like. She calls her grandma '
        'every Sunday and remembers everyone\'s birthday.',
    lines: [
      'When did you last call your family? Today is a great day.',
      'Send a friend a "thinking of you". It\'s like a hug by text.',
      'Hugs are free and I have unlimited ones.',
    ],
    doneLine: 'Big panda hug for you! You earned it.',
    unlockHint: 'Hatch from an egg',
    tint: Color(0xFFF3F2EE),
    art: CharacterArt(
      back:
          '<circle cx="15" cy="17" r="7" fill="#2C2C2A"/>'
          '<circle cx="49" cy="17" r="7" fill="#2C2C2A"/>',
      body:
          '<circle cx="32" cy="36" r="22" fill="#F1EFE8" stroke="#D3D1C7" stroke-width="1"/>'
          '<ellipse cx="23" cy="33" rx="6" ry="7.5" fill="#2C2C2A" transform="rotate(-20 23 33)"/>'
          '<ellipse cx="41" cy="33" rx="6" ry="7.5" fill="#2C2C2A" transform="rotate(20 41 33)"/>',
      eyes:
          '<circle cx="23.5" cy="33" r="2.4" fill="#FFFFFF"/>'
          '<circle cx="40.5" cy="33" r="2.4" fill="#FFFFFF"/>',
      blink:
          '<path d="M21 33.5 Q23.5 35.5 26 33.5 M38 33.5 Q40.5 35.5 43 33.5" '
          'stroke="#FFFFFF" stroke-width="1.8" fill="none" stroke-linecap="round"/>',
      face:
          '<ellipse cx="32" cy="41" rx="3" ry="2" fill="#2C2C2A"/>'
          '<path d="M29 45 Q32 48 35 45" stroke="#2C2C2A" stroke-width="1.6" '
          'fill="none" stroke-linecap="round"/>'
          '<ellipse cx="18" cy="43" rx="3.5" ry="2" fill="#F4C0D1"/>'
          '<ellipse cx="46" cy="43" rx="3.5" ry="2" fill="#F4C0D1"/>',
      top:
          '<path d="M44 3 L40 14" stroke="#639922" stroke-width="2.4" stroke-linecap="round"/>'
          '<path d="M42 7 Q48 4 50 8 Q45 10.5 42 7Z" fill="#97C459"/>',
    ),
    shinyColors: {'#2C2C2A': '#993556', '#F1EFE8': '#FBEAF0'},
  ),
  CrewCharacter(
    id: 'luna',
    name: 'Luna',
    species: 'owl',
    title: 'the night-time calmer',
    kind: 'Self-kindness',
    rarity: Rarity.rare,
    bio:
        'Luna stays up late so nobody has to feel alone at night. She reminds '
        'everyone that being kind to yourself counts too.',
    lines: [
      'Be as kind to yourself as you are to your friends.',
      'Drink some water. Stretch. You matter too.',
      'Rest is not lazy. Even stars take turns shining.',
    ],
    doneLine: 'Well done. Now take a breath, you deserve it.',
    unlockHint: 'Rare egg hatch',
    tint: Color(0xFFEEEDFE),
    art: CharacterArt(
      back: '<path d="M14 20 L17 6 L25 16 Z M50 20 L47 6 L39 16 Z" fill="#534AB7"/>',
      body:
          '<circle cx="32" cy="37" r="22" fill="#7F77DD"/>'
          '<ellipse cx="32" cy="46" rx="12" ry="10" fill="#CECBF6"/>'
          '<circle cx="23" cy="31" r="8" fill="#EEEDFE"/>'
          '<circle cx="41" cy="31" r="8" fill="#EEEDFE"/>',
      eyes:
          '<circle cx="23" cy="31" r="4.2" fill="#26215C"/>'
          '<circle cx="41" cy="31" r="4.2" fill="#26215C"/>'
          '<circle cx="24.5" cy="29.5" r="1.4" fill="#FFFFFF"/>'
          '<circle cx="42.5" cy="29.5" r="1.4" fill="#FFFFFF"/>',
      blink:
          '<path d="M18.5 31.5 Q23 35 27.5 31.5 M36.5 31.5 Q41 35 45.5 31.5" '
          'stroke="#26215C" stroke-width="2" fill="none" stroke-linecap="round"/>',
      face:
          '<path d="M29 38 L35 38 L32 42Z" fill="#EF9F27"/>'
          '<path d="M27 47 q2 2 4 0 M33 47 q2 2 4 0 M30 51 q2 2 4 0" '
          'stroke="#AFA9EC" stroke-width="1.2" fill="none"/>',
      top:
          '<path d="M50 5 l1.6 3.2 3.4 .5 -2.5 2.3 .6 3.4 -3.1 -1.6 -3.1 1.6 '
          '.6 -3.4 -2.5 -2.3 3.4 -.5Z" fill="#FAC775"/>',
    ),
    shinyColors: {
      '#7F77DD': '#2C2C2A',
      '#534AB7': '#444441',
      '#CECBF6': '#B4B2A9',
      '#EEEDFE': '#FAEEDA',
    },
  ),
  CrewCharacter(
    id: 'coral',
    name: 'Coral',
    species: 'whale',
    title: 'welcomes everyone',
    kind: 'Inclusion',
    rarity: Rarity.rare,
    bio:
        'Coral\'s ocean has room for every fish. She sings a welcome song to '
        'anyone who looks a little lonely.',
    lines: [
      'Invite someone new to sit with you today.',
      'Everyone has a story. Ask someone theirs.',
      'The ocean is big enough for all of us.',
    ],
    doneLine: 'You made someone feel welcome. That\'s a whale of a deed!',
    unlockHint: 'Rare egg hatch',
    tint: Color(0xFFE6F1FB),
    art: CharacterArt(
      back:
          '<path d="M26 15 Q23 7 28 4 M32 14 V3 M38 15 Q41 7 36 4" stroke="#85B7EB" '
          'stroke-width="2.4" fill="none" stroke-linecap="round"/>'
          '<path d="M53 40 Q62 28 62 38 Q62 47 55 46Z" fill="#378ADD"/>',
      body:
          '<path d="M6 40 Q6 18 31 18 Q56 18 56 40 Q56 58 31 58 Q6 58 6 40Z" fill="#378ADD"/>'
          '<path d="M12 45 Q31 60 50 45 Q48 56 31 56 Q15 56 12 45Z" fill="#B5D4F4"/>',
      eyes:
          '<circle cx="23" cy="35" r="3" fill="#042C53"/>'
          '<circle cx="39" cy="35" r="3" fill="#042C53"/>'
          '<circle cx="24" cy="34" r="1" fill="#FFFFFF"/>'
          '<circle cx="40" cy="34" r="1" fill="#FFFFFF"/>',
      blink:
          '<path d="M19.8 35.5 Q23 38 26.2 35.5 M35.8 35.5 Q39 38 42.2 35.5" '
          'stroke="#042C53" stroke-width="2" fill="none" stroke-linecap="round"/>',
      face:
          '<path d="M27 41 Q31 45 35 41" stroke="#042C53" stroke-width="2" '
          'fill="none" stroke-linecap="round"/>'
          '<ellipse cx="17" cy="40" rx="3" ry="2" fill="#F4C0D1"/>'
          '<ellipse cx="45" cy="40" rx="3" ry="2" fill="#F4C0D1"/>',
      top:
          '<circle cx="47" cy="12" r="3" fill="none" stroke="#85B7EB" stroke-width="1.4"/>'
          '<circle cx="53" cy="6" r="2" fill="none" stroke="#85B7EB" stroke-width="1.2"/>',
    ),
    shinyColors: {
      '#378ADD': '#D4537E',
      '#B5D4F4': '#FBEAF0',
      '#85B7EB': '#ED93B1',
    },
  ),
  CrewCharacter(
    id: 'kiwi',
    name: 'Kiwi',
    species: 'bunny',
    title: 'the explorer',
    kind: 'Every kind of kindness',
    rarity: Rarity.epic,
    bio:
        'Kiwi hopped around the whole world trying every kind of kindness. '
        'Her hat has a pin for each one.',
    lines: [
      'Try a kind act you\'ve never done before!',
      'Every kind of kindness is a new adventure.',
      'Hop, hop! Where shall we be kind today?',
    ],
    doneLine: 'Another adventure complete. Hop hop hooray!',
    unlockHint: 'Try 6 different kinds of kind acts',
    tint: Color(0xFFF7F1E4),
    art: CharacterArt(
      back:
          '<ellipse cx="23" cy="15" rx="5.5" ry="13" fill="#F1EFE8" stroke="#D3D1C7" '
          'stroke-width="1.2" transform="rotate(-10 23 15)"/>'
          '<ellipse cx="41" cy="15" rx="5.5" ry="13" fill="#F1EFE8" stroke="#D3D1C7" '
          'stroke-width="1.2" transform="rotate(10 41 15)"/>'
          '<ellipse cx="23" cy="16" rx="2.5" ry="9" fill="#F4C0D1" transform="rotate(-10 23 16)"/>'
          '<ellipse cx="41" cy="16" rx="2.5" ry="9" fill="#F4C0D1" transform="rotate(10 41 16)"/>',
      body: '<circle cx="32" cy="40" r="20" fill="#F1EFE8" stroke="#D3D1C7" stroke-width="1.2"/>',
      eyes:
          '<circle cx="25" cy="38" r="3" fill="#2C2C2A"/>'
          '<circle cx="39" cy="38" r="3" fill="#2C2C2A"/>'
          '<circle cx="26" cy="37" r="1" fill="#FFFFFF"/>'
          '<circle cx="40" cy="37" r="1" fill="#FFFFFF"/>',
      blink:
          '<path d="M21.8 38.5 Q25 41 28.2 38.5 M35.8 38.5 Q39 41 42.2 38.5" '
          'stroke="#2C2C2A" stroke-width="2" fill="none" stroke-linecap="round"/>',
      face:
          '<path d="M30.5 43 H33.5 L32 45Z" fill="#D4537E"/>'
          '<path d="M29 47 Q30.5 49 32 47 Q33.5 49 35 47" stroke="#2C2C2A" '
          'stroke-width="1.4" fill="none" stroke-linecap="round"/>'
          '<ellipse cx="20" cy="45" rx="3" ry="2" fill="#F4C0D1"/>'
          '<ellipse cx="44" cy="45" rx="3" ry="2" fill="#F4C0D1"/>',
      top:
          '<path d="M21 27 Q32 17 43 27 Z" fill="#BA7517"/>'
          '<rect x="17" y="25.5" width="30" height="3.4" rx="1.7" fill="#854F0B"/>'
          '<circle cx="37" cy="23.5" r="1.6" fill="#E24B4A"/>',
    ),
    shinyColors: {
      '#F1EFE8': '#FAC775',
      '#D3D1C7': '#BA7517',
      '#BA7517': '#3B6D11',
      '#854F0B': '#27500A',
    },
  ),
  CrewCharacter(
    id: 'sunny',
    name: 'Sunny',
    species: 'little sun',
    title: 'pure happiness',
    kind: '7-day streak',
    rarity: Rarity.epic,
    bio:
        'Sunny showed up on the seventh morning of a streak and never left. '
        'Nobody has ever seen Sunny frown.',
    lines: [
      'Good morning, superstar! Let\'s make today shine.',
      'Seven days of kindness made me. Imagine what\'s next!',
      'You light up rooms. I would know.',
    ],
    doneLine: 'You\'re glowing! Another bright day.',
    unlockHint: 'Reach a 7-day streak',
    tint: Color(0xFFFFF6DC),
    art: CharacterArt(
      back:
          '<g stroke="#EF9F27" stroke-width="3.4" stroke-linecap="round">'
          '<path d="M32 4V11M32 53V60M4 32H11M53 32H60M12 12L17 17M47 47L52 52M52 12L47 17M17 47L12 52"/>'
          '</g>',
      body: '<circle cx="32" cy="32" r="18" fill="#FAC775"/>',
      eyes:
          '<circle cx="26" cy="30" r="2.6" fill="#633806"/>'
          '<circle cx="38" cy="30" r="2.6" fill="#633806"/>'
          '<circle cx="27" cy="29" r="0.9" fill="#FFFFFF"/>'
          '<circle cx="39" cy="29" r="0.9" fill="#FFFFFF"/>',
      blink:
          '<path d="M23 30.5 Q26 33 29 30.5 M35 30.5 Q38 33 41 30.5" '
          'stroke="#633806" stroke-width="2" fill="none" stroke-linecap="round"/>',
      face:
          '<path d="M25.5 36 Q32 43 38.5 36Z" fill="#FFFFFF" stroke="#633806" '
          'stroke-width="2" stroke-linejoin="round"/>'
          '<ellipse cx="21" cy="35" rx="3" ry="2" fill="#F0997B"/>'
          '<ellipse cx="43" cy="35" rx="3" ry="2" fill="#F0997B"/>',
    ),
    shinyColors: {'#FAC775': '#F5C4B3', '#EF9F27': '#D85A30'},
  ),
  CrewCharacter(
    id: 'nova',
    name: 'Nova',
    species: 'star',
    title: 'the kindness legend',
    kind: '30-day streak',
    rarity: Rarity.legendary,
    bio:
        'Nova is made of thirty days of kindness, squeezed into one very '
        'bright star. Legends say she grants an extra smile to everyone nearby.',
    lines: [
      'Thirty days. You are officially a legend.',
      'Every kind act you do adds a little light to the sky.',
      'Stay kind, legend. The world needs your sparkle.',
    ],
    doneLine: 'Legendary as always. The sky is brighter tonight.',
    unlockHint: 'Reach a 30-day streak',
    tint: Color(0xFFF1EFFE),
    art: CharacterArt(
      back:
          '<circle cx="9" cy="15" r="1.6" fill="#FAC775"/>'
          '<circle cx="56" cy="20" r="1.6" fill="#FAC775"/>'
          '<circle cx="55" cy="52" r="1.2" fill="#FAC775"/>',
      body:
          '<path d="M32 12 L38.5 26.5 L54 27.5 L42 38 L46 54 L32 45.5 L18 54 L22 38 '
          'L10 27.5 L25.5 26.5Z" fill="#AFA9EC" stroke="#7F77DD" stroke-width="1.5" '
          'stroke-linejoin="round"/>',
      eyes:
          '<circle cx="27" cy="33" r="2.6" fill="#26215C"/>'
          '<circle cx="37" cy="33" r="2.6" fill="#26215C"/>'
          '<circle cx="28" cy="32" r="0.9" fill="#FFFFFF"/>'
          '<circle cx="38" cy="32" r="0.9" fill="#FFFFFF"/>',
      blink:
          '<path d="M24 33.5 Q27 36 30 33.5 M34 33.5 Q37 36 40 33.5" '
          'stroke="#26215C" stroke-width="2" fill="none" stroke-linecap="round"/>',
      face:
          '<path d="M29 38.5 Q32 41.5 35 38.5" stroke="#26215C" stroke-width="1.8" '
          'fill="none" stroke-linecap="round"/>'
          '<ellipse cx="23" cy="38" rx="2.4" ry="1.6" fill="#F4C0D1"/>'
          '<ellipse cx="41" cy="38" rx="2.4" ry="1.6" fill="#F4C0D1"/>',
      top:
          '<path d="M23 10 L26.5 14 L32 6 L37.5 14 L41 10 L40 17 H24Z" fill="#EF9F27" '
          'stroke="#BA7517" stroke-width="0.8"/>',
    ),
    shinyColors: {'#AFA9EC': '#FAC775', '#7F77DD': '#BA7517'},
  ),
];

CrewCharacter crewCharacter(String id) =>
    kCrew.firstWhere((c) => c.id == id, orElse: () => kCrew.first);

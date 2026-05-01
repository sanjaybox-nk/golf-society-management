class SeedingData {
  static const maleFirstNames = [
    'James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Charles', 
    'Daniel', 'Matthew', 'Anthony', 'Donald', 'Mark', 'Paul', 'Steven', 'Andrew', 'Kenneth', 'Joshua', 
    'Kevin', 'Brian', 'George', 'Edward', 'Ronald', 'Timothy', 'Jason', 'Jeffrey', 'Ryan', 'Jacob',
    'Gary', 'Nicholas', 'Eric', 'Stephen', 'Jonathan', 'Larry', 'Justin', 'Scott', 'Brandon', 'Frank',
    'Benjamin', 'Gregory', 'Samuel', 'Raymond', 'Patrick', 'Alexander', 'Jack', 'Dennis', 'Jerry', 'Tyler'
  ];
  
  static const femaleFirstNames = [
    'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen', 
    'Nancy', 'Lisa', 'Margaret', 'Betty', 'Sandra', 'Ashley', 'Dorothy', 'Kimberly', 'Emily', 'Donna',
    'Michelle', 'Carol', 'Amanda', 'Melissa', 'Deborah'
  ];
  
  static const lastNames = [
    'Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 
    'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson', 
    'Clark', 'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'Hernandez', 'King',
    'Wright', 'Lopez', 'Hill', 'Scott', 'Green', 'Adams', 'Baker', 'Gonzalez', 'Nelson', 'Carter',
    'Mitchell', 'Perez', 'Roberts', 'Turner', 'Phillips', 'Campbell', 'Parker', 'Evans', 'Edwards', 'Collins'
  ];
  
  static final maleAvatarUrls = [
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80', // Man 1
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80', // Man 2
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80', // Man 3
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=80', // Man 4
    'https://images.unsplash.com/photo-1542156822-6924d1a71ace?auto=format&fit=crop&w=200&q=80', // Man 5
    'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=200&q=80', // Man 6
    'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=200&q=80', // Man 7
    'https://images.unsplash.com/photo-1513910367299-bce8d8a0ebf6?auto=format&fit=crop&w=200&q=80', // Man 8
    'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?auto=format&fit=crop&w=200&q=80', // Man 9
    'https://images.unsplash.com/photo-1520341280432-4749d4d7bcf9?auto=format&fit=crop&w=200&q=80', // Man 10
    // Generate more unique patterns for larger sets
    for (int i = 11; i <= 100; i++) 'https://randomuser.me/api/portraits/men/$i.jpg',
  ];
  
  static final femaleAvatarUrls = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80', // Woman 1
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80', // Woman 2
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80', // Woman 3
    'https://images.unsplash.com/photo-1554151228-14d9def656e4?auto=format&fit=crop&w=200&q=80', // Woman 4
    'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=200&q=80', // Woman 5
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=200&q=80', // Woman 6
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80', // Woman 7
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80', // Woman 8
    'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=200&q=80', // Woman 9
    'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?auto=format&fit=crop&w=200&q=80', // Woman 10
    for (int i = 11; i <= 100; i++) 'https://randomuser.me/api/portraits/women/$i.jpg',
  ];

  static const courseAddresses = {
    'St Andrews': 'West Sands Rd, St Andrews KY16 9XL, Scotland',
    'Pebble Beach': '1700 17 Mile Dr, Pebble Beach, CA 93953, USA',
    'TPC Sawgrass': '110 Championship Way, Ponte Vedra Beach, FL 32082, USA',
    'Augusta': '2604 Washington Rd, Augusta, GA 30904, USA',
    'Royal County Down': '36 Golf Links Rd, Newcastle BT33 0AN, Northern Ireland',
    'Muirfield': 'Duncur Rd, Gullane EH31 2EG, Scotland',
    'Shinnecock Hills': '200 Tuckahoe Rd, Southampton, NY 11968, USA',
    'Oakmont': '1233 Hulton Rd, Oakmont, PA 15139, USA',
    'Cypress Point': '3150 17 Mile Dr, Pebble Beach, CA 93953, USA',
    'Pine Valley': '1 E Atlantic Ave, Pine Hill, NJ 08021, USA',
    'Royal Melbourne': 'Cheltenham Rd, Black Rock VIC 3193, Australia',
    'Dom Pedro Old Course': 'Volta do Parque 8125-507, Vilamoura, Portugal',
    'Victoria Golf Course': 'Av. dos Descobrimentos, 8125-507 Vilamoura, Portugal',
  };

  static const memberAddresses = [
    '12 High Street, Marlow, SL7 1AB',
    '45 The Avenue, Reading, RG1 5TY',
    '78 Riverside Drive, Windsor, SL4 5NP',
    '23 Park Lane, London, W1K 1BE',
    '56 Church Road, Henley, RG9 1RS',
    '89 Station Road, Beaconsfield, HP9 1QL',
    '15 Meadow View, Maidenhead, SL6 7HJ',
    '34 Cedar Close, Bracknell, RG12 9JU',
    '67 Oak Ridge, Wokingham, RG40 2TR',
    '92 Hillside Avenue, Slough, SL1 2PQ',
  ];
}

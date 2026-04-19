CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  adjectives_json constant jsonb := $adj$["mad","sad","bad","rad","odd","hot","cold","cool","warm","chill", "fast","slow","big","small","tiny","mini","mega","ultra","hyper","max", "low","high","mid","top","prime","core","base","edge","peak","zen", "wild","calm","bold","shy","lazy","busy","dead","live","true","fake", "dark","light","neon","gold","blue","red","pink","gray","black","white", "soft","hard","flat","sharp","round","bent","clean","dirty","rough","smooth", "sweet","sour","salty","spicy","dry","wet","juicy","greasy","fresh","rotten", "nice","mean","kind","rude","weird","rare","epic","myth","lost","found", "hidden","open","close","locked","free","paid","rich","poor","young","old", "new","used","ancient","modern","future","retro","vintage","classic","royal","noble", "elite","super","basic","final","early","late","next","safe","risky","danger", "deadly","fatal","toxic","messy","neat","solid","liquid","gassy","heavy","light", "loose","tight","stiff","rigid","bouncy","sticky","slippy","crunchy","blunt","pointy", "broken","fixed","bitter","icy","storm","windy","rainy","snowy","foggy","dusty", "smoky","burnt","charred","melted","frozen","boiled","chilled","heated","cooled","empty", "full","half","total","maxed","min","mythic","godly","noob","pro","upper", "lower","inner","outer","near","far","distant","first","start","end","quick", "rapid","swift","turbo","speed","flash","bright","dim","clear","fuzzy","shiny", "matte","glossy","grimy","soaked","baked","raw","cooked","spiked","salted","sugary", "tasty","gross","loud","quiet","silent","noisy","brave","scared","afraid","sleepy", "tired","awake","alert","silly","funny","goofy","lucky","unlucky","lethal","stable", "active","passive","hostile","friendly","social","direct","random","linear","global","local", "public","private","secure","closed","simple","complex","smart","dumb","wise","naive", "steady","ready","real","pure","mixed","dual","mono","multi","alpha","beta", "gamma","delta","omega","sigma","void","neo","xeno","deep","wide","tall", "short","long","brief","thick","thin","crispy","chewy","soggy","minty","zesty", "spongy","fluffy","hairy","spiky","slimy","grainy","blocky","chunky","lumpy","bumpy", "jagged","curved","angled","hollow","dense","airy","moist","damp","dryish","humid", "breezy","gusty","stormy","sunny","cloudy","frosty","lukewarm","fading","glowing","blazing", "flicker","glimmer","shaded","shadow","murky","fogged","blurred","darker","lighter","coolish", "warmish","reddish","bluish","greeny","golden","silver","bronze","copper","rusty","metal", "wooden","stone","marble","granite","rubber","plastic","glassy","crystal","tacky","slick", "oily","buttery","creamy","foamy","bubbly","fizzy","smelly","stinky","minted","zany", "quirky","funky","groovy","jazzy","snazzy","flashy","showy","lively","rowdy","calmer", "wilder","brisk","speedy","zippy","nippy","snappy","cranky","grumpy","moody","angsty", "happy","cheery","jolly","merry","gloomy","dreary","bleak","darkish","sunlit","moonlit", "starlit","cosmic","astral","spacey","timely","timed","soon","firm","loyal","trusty", "honest","brutal","harsh","tough","gentle","mellow","clicky","tappy","crashy","smashy", "bangy","boomy","zappy","poppy","buggy","laggy","pingy","syncy","coded","hacked", "modded","rooted","framed","pixely","bitty","bytey","binary","digital","online","offline", "streamy","loaded","saved","synced","cached","linked","wired","remote","opened","shown", "seen","unseen","visible","masked","secret","covert","stealth","curvy","shapely","formy" ]$adj$::jsonb;
  nouns_json constant jsonb := $noun$["wolf","tiger","lion","bear","fox","eagle","hawk","shark","whale","dolphin", "snake","cobra","viper","python","lizard","dragon","falcon","owl","crow","raven", "panda","koala","monkey","gorilla","chimp","dog","cat","mouse","rat","hamster", "rabbit","deer","horse","zebra","camel","goat","sheep","cow","bull","pig", "boar","rooster","duck","goose","turkey","carp","salmon","tuna","octopus","squid", "crab","lobster","shrimp","ant","bee","wasp","spider","scorpion","butterfly","moth", "beetle","mosquito","frog","toad","seal","penguin","otter","badger","weasel","ferret", "lynx","panther","cheetah","leopard","hyena","yak","buffalo","bison","donkey","mule", "apple","banana","orange","lemon","lime","grape","melon","peach","pear","plum", "cherry","mango","papaya","kiwi","pineapple","coconut","fig","date","apricot","bread", "toast","pizza","burger","fries","pasta","noodle","rice","sushi","ramen","steak", "meat","beef","pork","bacon","sausage","egg","cheese","butter","milk","cream", "yogurt","cake","cookie","biscuit","donut","candy","sugar","honey","jam","syrup", "salt","spice","pepper","garlic","onion","carrot","potato","tomato","salad","soup", "sauce","ketchup","mustard","mayo","oil","vinegar","herb","tea","coffee","latte", "mocha","juice","soda","cola","water","beer","wine","smoothie","waffle","pancake", "croissant","bagel","pretzel","sandwich","wrap","taco","burrito","nacho","cheddar","brie", "grain","oat","wheat","corn","barley", "chair","table","desk","sofa","couch","bed","lamp","light","bulb","screen", "phone","laptop","tablet","mouse","keyboard","monitor","camera","speaker","radio","clock", "watch","bag","wallet","bottle","glass","cup","plate","fork","knife","spoon", "pan","pot","oven","fridge","freezer","door","window","mirror","frame","box", "case","tool","hammer","drill","screw","nail","rope","chain","lock","key", "car","truck","bike","motor","engine","wheel","tire","seat","belt","helmet", "plane","jet","train","metro","bus","ship","boat","canoe","rocket","drone", "paper","book","note","card","coin","cash","chip","disk","cable","wire", "forest","jungle","desert","ocean","sea","river","lake","pond","island","beach", "shore","coast","cliff","hill","mount","valley","canyon","field","plain","sky", "cloud","storm","rain","snow","wind","fog","mist","sun","moon","star", "space","void","earth","rock","stone","sand","dust","ash","lava","ice", "glacier","tree","plant","grass","leaf","flower","root","branch","seed","wood", "bush","vine","moss","fungi","coral","reef","wave","tide","current","breeze", "piano","guitar","drum","violin","flute","trumpet","sax","bass","harp","cello", "ball","bat","racket","goal","net","ring","dice","token","cube","brick", "block","tile","pixel","panel","grid","node","server","data","code","script", "bot","core","cache","stack","loop","thread","byte","bit","signal","pulse", "beam","ray","laser","shield","blade","sword","arrow","bow","gun","bomb", "tank","armor","gear","kit","pack","crate","device","module", "pebble","crystal","gem","diamond","gold","silver","bronze","iron","steel","metal", "copper","zinc","lead","clay","soil","mud","steam","smoke","flame","fire", "ember","spark","shadow","bark","log","grove","swamp","marsh","bog","gust", "hail","orbit","comet","meteor","planet","galaxy","cosmos","nebula","asteroid", "bench","stool","locker","drawer","cabinet","shelf","closet","garage","roof","floor", "ceiling","hinge","handle","switch","button","lever","dial","gauge","sensor","circuit", "battery","charger","adapter","router","modem","antenna","satdish", "boots","gloves","jacket","coat","hoodie","shirt","pants","jeans","shorts","sneaker", "trainer","slipper","sock","backpack","briefcase","pouch","satchel","duffel", "lantern","torch","flashlight","candle","lighter","match","fuse","plug","socket","outlet", "generator","turbine","reactor","fuel","diesel", "notebook","sketch","journal","planner","calendar","ticket","passport","license","badge","receipt", "invoice","contract","report","manual","guide","map","blueprint","diagram", "console","arcade","joystick","gamepad","headset","earbuds","microphone","projector","datacenter","cluster", "mainframe","serverrack","firewall","gateway","switchboard","nodegrid","backplane","motherboard","microchip","nanobot", "exosuit","spacesuit","airlock","thruster","warpdrive","stardrive","reactorcore","powercell","fuelcell","coolant", "radiator","fanblade","propeller","rotor","gearbox","clutch","axle","chassis","cockpit","dashboard", "odometer","compass","barometer","thermometer","altimeter","microscope","telescope","binocular","canvas","palette", "paintbrush","inkwell","quill","printer","scanner","photocopier","stapler","envelope","mailbox","package", "parcel","lockbox","safe","strongbox","ledger","clipboard","notepad","sketchpad","cratebox","latch", "padlock","deadbolt","doorknob","handlebar","seatpost","saddle","pedal","chainring","derailleur","spoke", "rim","hub","valve","nozzle","faucet","shower","bathtub","sink","drain","plunger", "wrench","pliers","cutter","shears","chainsaw","drillbit","vise","clamp","level","square", "ruler","caliper","bearing","bushing","gasket","spring","damper","shock","bracket","mount", "batterybox","powerbank","capacitor","resistor","transistor","relay","inverter" ]$noun$::jsonb;
  adjectives text[];
  nouns text[];
  adjectives_count integer;
  nouns_count integer;
  generated_username text;
  attempt integer;
  digest bytea;
BEGIN
  SELECT array_agg(value) INTO adjectives
  FROM jsonb_array_elements_text(adjectives_json);

  SELECT array_agg(value) INTO nouns
  FROM jsonb_array_elements_text(nouns_json);

  adjectives_count := COALESCE(array_length(adjectives, 1), 0);
  nouns_count := COALESCE(array_length(nouns, 1), 0);

  IF adjectives_count = 0 OR nouns_count = 0 THEN
    RAISE EXCEPTION 'username word lists are empty';
  END IF;

  FOR attempt IN 1..30 LOOP
    generated_username :=
      adjectives[(floor(random() * adjectives_count)::int + 1)] ||
      nouns[(floor(random() * nouns_count)::int + 1)] ||
      (floor(random() * 100)::int)::text;

    EXIT WHEN NOT EXISTS (
      SELECT 1
      FROM profiles p
      WHERE p.username = generated_username
    );
  END LOOP;

  IF EXISTS (
    SELECT 1
    FROM profiles p
    WHERE p.username = generated_username
  ) THEN
    FOR attempt IN 0..500 LOOP
      digest := decode(md5(NEW.id::text || ':' || attempt::text), 'hex');
      generated_username :=
        adjectives[((get_byte(digest, 0) * 256 + get_byte(digest, 1)) % adjectives_count) + 1] ||
        nouns[((get_byte(digest, 2) * 256 + get_byte(digest, 3)) % nouns_count) + 1] ||
        (get_byte(digest, 4) % 100)::text;

      EXIT WHEN NOT EXISTS (
        SELECT 1
        FROM profiles p
        WHERE p.username = generated_username
      );
    END LOOP;
  END IF;

  INSERT INTO profiles (id, username, onboarding_completed)
  VALUES (NEW.id, generated_username, false)
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

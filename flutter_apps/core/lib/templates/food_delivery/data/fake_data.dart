import 'package:flutter/painting.dart';

import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/restaurant.dart';

const fakeCategories = [
  FoodCategory(id: 'pizza', label: 'Pizza', kind: DishKind.pizza),
  FoodCategory(id: 'noodles', label: 'Noodles', kind: DishKind.ramen),
  FoodCategory(id: 'burgers', label: 'Burgers', kind: DishKind.burger),
  FoodCategory(id: 'mexican', label: 'Mexican', kind: DishKind.taco),
  FoodCategory(id: 'healthy', label: 'Healthy', kind: DishKind.salad),
  FoodCategory(id: 'sushi', label: 'Sushi', kind: DishKind.sushi),
  FoodCategory(id: 'indian', label: 'Indian', kind: DishKind.curry),
  FoodCategory(id: 'sweets', label: 'Sweets', kind: DishKind.cake),
];

const fakePromoCodes = {
  'WELCOME10': PromoCode(
    code: 'WELCOME10',
    label: '10% off your order',
    percentOff: 10,
  ),
  'FREESHIP': PromoCode(
    code: 'FREESHIP',
    label: 'Free delivery',
    freeDelivery: true,
  ),
};

const _pizzaSize = OptionGroup(
  id: 'size',
  title: 'Size',
  minSelected: 1,
  options: [
    ItemOption(id: 'size-10', name: '10 inch'),
    ItemOption(id: 'size-12', name: '12 inch', priceCents: 300),
    ItemOption(id: 'size-14', name: '14 inch', priceCents: 550),
  ],
);

const _pizzaExtras = OptionGroup(
  id: 'extras',
  title: 'Extra toppings',
  maxSelected: 3,
  options: [
    ItemOption(id: 'x-mozz', name: 'Buffalo mozzarella', priceCents: 200),
    ItemOption(id: 'x-olive', name: 'Black olives', priceCents: 120),
    ItemOption(id: 'x-chili', name: 'Calabrian chili', priceCents: 120),
    ItemOption(id: 'x-shroom', name: 'Roast mushrooms', priceCents: 150),
  ],
);

const _spice = OptionGroup(
  id: 'spice',
  title: 'Spice level',
  minSelected: 1,
  options: [
    ItemOption(id: 'sp-mild', name: 'Mild'),
    ItemOption(id: 'sp-med', name: 'Medium'),
    ItemOption(id: 'sp-hot', name: 'Hot'),
  ],
);

const _ramenAddOns = OptionGroup(
  id: 'addons',
  title: 'Add-ons',
  maxSelected: 4,
  options: [
    ItemOption(id: 'r-egg', name: 'Soft egg', priceCents: 180),
    ItemOption(id: 'r-pork', name: 'Extra chashu', priceCents: 350),
    ItemOption(id: 'r-corn', name: 'Butter corn', priceCents: 120),
    ItemOption(id: 'r-nori', name: 'Nori sheets', priceCents: 90),
  ],
);

const _burgerDoneness = OptionGroup(
  id: 'patty',
  title: 'Patty',
  minSelected: 1,
  options: [
    ItemOption(id: 'p-single', name: 'Single'),
    ItemOption(id: 'p-double', name: 'Double', priceCents: 320),
    ItemOption(id: 'p-plant', name: 'Plant based', priceCents: 150),
  ],
);

const _burgerExtras = OptionGroup(
  id: 'extras',
  title: 'Make it yours',
  maxSelected: 4,
  options: [
    ItemOption(id: 'b-bacon', name: 'Smoked bacon', priceCents: 220),
    ItemOption(id: 'b-cheese', name: 'Extra cheddar', priceCents: 120),
    ItemOption(id: 'b-pickle', name: 'Extra pickles'),
    ItemOption(id: 'b-onion', name: 'Crispy onions', priceCents: 100),
  ],
);

const _tacoProtein = OptionGroup(
  id: 'protein',
  title: 'Filling',
  minSelected: 1,
  options: [
    ItemOption(id: 't-pastor', name: 'Al pastor'),
    ItemOption(id: 't-carnitas', name: 'Carnitas'),
    ItemOption(id: 't-mush', name: 'Chili mushrooms'),
    ItemOption(id: 't-shrimp', name: 'Garlic shrimp', priceCents: 200),
  ],
);

const _bowlBase = OptionGroup(
  id: 'base',
  title: 'Base',
  minSelected: 1,
  options: [
    ItemOption(id: 'g-kale', name: 'Kale and romaine'),
    ItemOption(id: 'g-rice', name: 'Brown rice'),
    ItemOption(id: 'g-quinoa', name: 'Quinoa', priceCents: 100),
  ],
);

const _bowlExtras = OptionGroup(
  id: 'extras',
  title: 'Top it',
  minSelected: 1,
  maxSelected: 3,
  options: [
    ItemOption(id: 'g-avo', name: 'Avocado', priceCents: 180),
    ItemOption(id: 'g-egg', name: 'Jammy egg', priceCents: 120),
    ItemOption(id: 'g-seed', name: 'Toasted seeds'),
    ItemOption(id: 'g-feta', name: 'Feta', priceCents: 130),
  ],
);

const _sushiSides = OptionGroup(
  id: 'sides',
  title: 'On the side',
  maxSelected: 2,
  options: [
    ItemOption(id: 's-ginger', name: 'Extra ginger'),
    ItemOption(id: 's-wasabi', name: 'Fresh wasabi', priceCents: 150),
    ItemOption(id: 's-soy', name: 'Low sodium soy'),
  ],
);

const _curryRice = OptionGroup(
  id: 'rice',
  title: 'Served with',
  minSelected: 1,
  options: [
    ItemOption(id: 'c-basmati', name: 'Basmati rice'),
    ItemOption(id: 'c-jeera', name: 'Jeera rice', priceCents: 80),
    ItemOption(id: 'c-naan', name: 'Garlic naan', priceCents: 150),
  ],
);

const _sliceSize = OptionGroup(
  id: 'size',
  title: 'Portion',
  minSelected: 1,
  options: [
    ItemOption(id: 'd-slice', name: 'Slice'),
    ItemOption(id: 'd-whole', name: 'Whole 6 inch', priceCents: 1800),
  ],
);

const _drinkSize = OptionGroup(
  id: 'size',
  title: 'Size',
  minSelected: 1,
  options: [
    ItemOption(id: 'dk-reg', name: 'Regular'),
    ItemOption(id: 'dk-lg', name: 'Large', priceCents: 120),
  ],
);

const fakeRestaurants = [
  Restaurant(
    id: 'forno-rosso',
    name: 'Forno Rosso',
    cuisine: 'Wood-fired pizza',
    categoryId: 'pizza',
    seedColor: Color(0xFFC62828),
    kind: DishKind.pizza,
    rating: 4.8,
    reviewCount: 1240,
    etaMinutes: 25,
    deliveryFeeCents: 199,
    minimumOrderCents: 1200,
    distanceKm: 1.4,
    sections: [
      MenuSection(
        title: 'Pizza',
        items: [
          MenuItem(
            id: 'fr-margherita',
            name: 'Margherita',
            description: 'San Marzano tomato, fior di latte, basil, olive oil.',
            priceCents: 1250,
            kind: DishKind.pizza,
            popular: true,
            optionGroups: [_pizzaSize, _pizzaExtras],
          ),
          MenuItem(
            id: 'fr-diavola',
            name: 'Diavola',
            description: 'Spicy salami, smoked provola, honey, chili flakes.',
            priceCents: 1490,
            kind: DishKind.pizza,
            optionGroups: [_pizzaSize, _pizzaExtras],
          ),
          MenuItem(
            id: 'fr-bianca',
            name: 'Funghi Bianca',
            description: 'Garlic cream, roast mushrooms, thyme, parmesan.',
            priceCents: 1420,
            kind: DishKind.pizza,
            optionGroups: [_pizzaSize, _pizzaExtras],
          ),
        ],
      ),
      MenuSection(
        title: 'Sides',
        items: [
          MenuItem(
            id: 'fr-salad',
            name: 'Rocket Salad',
            description: 'Rocket, shaved parmesan, lemon dressing.',
            priceCents: 780,
            kind: DishKind.salad,
          ),
          MenuItem(
            id: 'fr-fries',
            name: 'Rosemary Fries',
            description: 'Crisp fries with rosemary salt and aioli.',
            priceCents: 620,
            kind: DishKind.fries,
          ),
        ],
      ),
      MenuSection(
        title: 'Dessert and drinks',
        items: [
          MenuItem(
            id: 'fr-tiramisu',
            name: 'Tiramisu',
            description: 'Espresso soaked savoiardi, mascarpone, cocoa.',
            priceCents: 690,
            kind: DishKind.cake,
          ),
          MenuItem(
            id: 'fr-soda',
            name: 'Blood Orange Soda',
            description: 'Italian sparkling soda, served cold.',
            priceCents: 390,
            kind: DishKind.drink,
          ),
        ],
      ),
    ],
  ),
  Restaurant(
    id: 'kumo-ramen',
    name: 'Kumo Ramen',
    cuisine: 'Japanese noodles',
    categoryId: 'noodles',
    seedColor: Color(0xFF3949AB),
    kind: DishKind.ramen,
    rating: 4.7,
    reviewCount: 860,
    etaMinutes: 30,
    deliveryFeeCents: 249,
    minimumOrderCents: 1500,
    distanceKm: 2.1,
    sections: [
      MenuSection(
        title: 'Ramen',
        items: [
          MenuItem(
            id: 'kr-tonkotsu',
            name: 'Tonkotsu',
            description: '18 hour pork broth, chashu, wood ear, spring onion.',
            priceCents: 1590,
            kind: DishKind.ramen,
            popular: true,
            optionGroups: [_spice, _ramenAddOns],
          ),
          MenuItem(
            id: 'kr-miso',
            name: 'Red Miso',
            description: 'Miso broth, ground pork, corn, bean sprouts.',
            priceCents: 1540,
            kind: DishKind.ramen,
            optionGroups: [_spice, _ramenAddOns],
          ),
          MenuItem(
            id: 'kr-shoyu',
            name: 'Mushroom Shoyu',
            description: 'Vegan shiitake broth, tofu, greens, sesame.',
            priceCents: 1460,
            kind: DishKind.ramen,
            optionGroups: [_spice, _ramenAddOns],
          ),
        ],
      ),
      MenuSection(
        title: 'Small plates',
        items: [
          MenuItem(
            id: 'kr-karaage',
            name: 'Karaage',
            description: 'Crisp soy marinated chicken with yuzu mayo.',
            priceCents: 850,
            kind: DishKind.fries,
          ),
          MenuItem(
            id: 'kr-tea',
            name: 'Iced Barley Tea',
            description: 'Roasted and unsweetened.',
            priceCents: 350,
            kind: DishKind.drink,
            optionGroups: [_drinkSize],
          ),
        ],
      ),
    ],
  ),
  Restaurant(
    id: 'smash-alley',
    name: 'Smash Alley',
    cuisine: 'Smashed burgers',
    categoryId: 'burgers',
    seedColor: Color(0xFFE09F00),
    kind: DishKind.burger,
    rating: 4.6,
    reviewCount: 2105,
    etaMinutes: 20,
    deliveryFeeCents: 0,
    minimumOrderCents: 1000,
    distanceKm: 0.9,
    sections: [
      MenuSection(
        title: 'Burgers',
        items: [
          MenuItem(
            id: 'sa-classic',
            name: 'The Alley Classic',
            description: 'Crisp edge patty, American cheese, house sauce.',
            priceCents: 1095,
            kind: DishKind.burger,
            popular: true,
            optionGroups: [_burgerDoneness, _burgerExtras],
          ),
          MenuItem(
            id: 'sa-hot',
            name: 'Hot Honey Chicken',
            description: 'Fried thigh, hot honey, slaw, pickles.',
            priceCents: 1195,
            kind: DishKind.burger,
            optionGroups: [_burgerExtras],
          ),
        ],
      ),
      MenuSection(
        title: 'Sides and shakes',
        items: [
          MenuItem(
            id: 'sa-fries',
            name: 'Shoestring Fries',
            description: 'Thin cut, double fried, sea salt.',
            priceCents: 495,
            kind: DishKind.fries,
          ),
          MenuItem(
            id: 'sa-shake',
            name: 'Malted Shake',
            description: 'Vanilla custard and barley malt.',
            priceCents: 650,
            kind: DishKind.drink,
            optionGroups: [_drinkSize],
          ),
        ],
      ),
    ],
  ),
  Restaurant(
    id: 'taqueria-luz',
    name: 'Taqueria Luz',
    cuisine: 'Street tacos',
    categoryId: 'mexican',
    seedColor: Color(0xFFD81B60),
    kind: DishKind.taco,
    rating: 4.9,
    reviewCount: 640,
    etaMinutes: 22,
    deliveryFeeCents: 149,
    minimumOrderCents: 1000,
    distanceKm: 1.2,
    sections: [
      MenuSection(
        title: 'Tacos',
        items: [
          MenuItem(
            id: 'tl-trio',
            name: 'Taco Trio',
            description: 'Three corn tortillas, onion, cilantro, salsa verde.',
            priceCents: 1150,
            kind: DishKind.taco,
            popular: true,
            optionGroups: [_tacoProtein, _spice],
          ),
          MenuItem(
            id: 'tl-quesa',
            name: 'Birria Quesataco',
            description: 'Crisp cheese taco with a cup of rich consomme.',
            priceCents: 1290,
            kind: DishKind.taco,
            optionGroups: [_spice],
          ),
        ],
      ),
      MenuSection(
        title: 'On the side',
        items: [
          MenuItem(
            id: 'tl-elote',
            name: 'Elote Bowl',
            description: 'Charred corn, cotija, lime, tajin.',
            priceCents: 640,
            kind: DishKind.salad,
          ),
          MenuItem(
            id: 'tl-horchata',
            name: 'Horchata',
            description: 'Rice milk, cinnamon, vanilla.',
            priceCents: 420,
            kind: DishKind.drink,
            optionGroups: [_drinkSize],
          ),
        ],
      ),
    ],
  ),
  Restaurant(
    id: 'field-bowl',
    name: 'Field Bowl',
    cuisine: 'Salads and grains',
    categoryId: 'healthy',
    seedColor: Color(0xFF558B2F),
    kind: DishKind.salad,
    rating: 4.5,
    reviewCount: 530,
    etaMinutes: 18,
    deliveryFeeCents: 99,
    minimumOrderCents: 1100,
    distanceKm: 0.7,
    sections: [
      MenuSection(
        title: 'Bowls',
        items: [
          MenuItem(
            id: 'fb-harvest',
            name: 'Harvest Bowl',
            description: 'Roast squash, apple, pecans, maple mustard.',
            priceCents: 1320,
            kind: DishKind.salad,
            popular: true,
            optionGroups: [_bowlBase, _bowlExtras],
          ),
          MenuItem(
            id: 'fb-green',
            name: 'Green Goddess',
            description: 'Broccoli, cucumber, herbs, tahini dressing.',
            priceCents: 1250,
            kind: DishKind.salad,
            optionGroups: [_bowlBase, _bowlExtras],
          ),
        ],
      ),
      MenuSection(
        title: 'Drinks',
        items: [
          MenuItem(
            id: 'fb-juice',
            name: 'Cold Pressed Green',
            description: 'Apple, celery, spinach, ginger.',
            priceCents: 590,
            kind: DishKind.drink,
          ),
        ],
      ),
    ],
  ),
  Restaurant(
    id: 'sora-sushi',
    name: 'Sora Sushi',
    cuisine: 'Rolls and sashimi',
    categoryId: 'sushi',
    seedColor: Color(0xFF00838F),
    kind: DishKind.sushi,
    rating: 4.8,
    reviewCount: 980,
    etaMinutes: 35,
    deliveryFeeCents: 299,
    minimumOrderCents: 2000,
    distanceKm: 3.2,
    sections: [
      MenuSection(
        title: 'Rolls',
        items: [
          MenuItem(
            id: 'ss-salmon',
            name: 'Salmon Avocado Roll',
            description: 'Eight pieces with sesame and scallion.',
            priceCents: 1180,
            kind: DishKind.sushi,
            popular: true,
            optionGroups: [_sushiSides],
          ),
          MenuItem(
            id: 'ss-spicy',
            name: 'Spicy Tuna Roll',
            description: 'Eight pieces with chili mayo and tempura crunch.',
            priceCents: 1260,
            kind: DishKind.sushi,
            optionGroups: [_sushiSides],
          ),
          MenuItem(
            id: 'ss-platter',
            name: 'Chef Platter',
            description: 'Twenty-four pieces chosen by the chef.',
            priceCents: 3200,
            kind: DishKind.sushi,
            optionGroups: [_sushiSides],
          ),
        ],
      ),
      MenuSection(
        title: 'Warm',
        items: [
          MenuItem(
            id: 'ss-miso',
            name: 'Miso Soup',
            description: 'Silken tofu, wakame, spring onion.',
            priceCents: 390,
            kind: DishKind.ramen,
          ),
        ],
      ),
    ],
  ),
  Restaurant(
    id: 'masala-yard',
    name: 'Masala Yard',
    cuisine: 'North Indian curries',
    categoryId: 'indian',
    seedColor: Color(0xFFE65100),
    kind: DishKind.curry,
    rating: 4.7,
    reviewCount: 1510,
    etaMinutes: 32,
    deliveryFeeCents: 199,
    minimumOrderCents: 1500,
    distanceKm: 2.6,
    sections: [
      MenuSection(
        title: 'Curries',
        items: [
          MenuItem(
            id: 'my-butter',
            name: 'Butter Chicken',
            description: 'Tandoor chicken in tomato and fenugreek gravy.',
            priceCents: 1520,
            kind: DishKind.curry,
            popular: true,
            optionGroups: [_curryRice, _spice],
          ),
          MenuItem(
            id: 'my-palak',
            name: 'Palak Paneer',
            description: 'Fresh cheese in spiced spinach.',
            priceCents: 1390,
            kind: DishKind.curry,
            optionGroups: [_curryRice, _spice],
          ),
          MenuItem(
            id: 'my-dal',
            name: 'Dal Makhani',
            description: 'Black lentils simmered overnight.',
            priceCents: 1190,
            kind: DishKind.curry,
            optionGroups: [_curryRice],
          ),
        ],
      ),
      MenuSection(
        title: 'Drinks',
        items: [
          MenuItem(
            id: 'my-lassi',
            name: 'Mango Lassi',
            description: 'Yogurt, alphonso mango, cardamom.',
            priceCents: 480,
            kind: DishKind.drink,
            optionGroups: [_drinkSize],
          ),
        ],
      ),
    ],
  ),
  Restaurant(
    id: 'sugar-loaf',
    name: 'Sugar Loaf',
    cuisine: 'Cakes and pastry',
    categoryId: 'sweets',
    seedColor: Color(0xFF8E24AA),
    kind: DishKind.cake,
    rating: 4.9,
    reviewCount: 410,
    etaMinutes: 24,
    deliveryFeeCents: 149,
    minimumOrderCents: 800,
    distanceKm: 1.8,
    sections: [
      MenuSection(
        title: 'Cakes',
        items: [
          MenuItem(
            id: 'sl-basque',
            name: 'Basque Cheesecake',
            description: 'Burnt top, soft centre, no crust.',
            priceCents: 780,
            kind: DishKind.cake,
            popular: true,
            optionGroups: [_sliceSize],
          ),
          MenuItem(
            id: 'sl-berry',
            name: 'Berry Tart',
            description: 'Vanilla custard, seasonal berries, almond crust.',
            priceCents: 720,
            kind: DishKind.cake,
            optionGroups: [_sliceSize],
          ),
        ],
      ),
      MenuSection(
        title: 'Drinks',
        items: [
          MenuItem(
            id: 'sl-latte',
            name: 'Oat Latte',
            description: 'Double shot, steamed oat milk.',
            priceCents: 480,
            kind: DishKind.drink,
            optionGroups: [_drinkSize],
          ),
        ],
      ),
    ],
  ),
];

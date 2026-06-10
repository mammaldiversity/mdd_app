class MammalianOrders {
  /// Constant map of mammalian orders (in lowercase) to their common names,
  /// ordered following the Mammal Diversity Database (MDD) taxonomy.
  /// Ordered based on MDD v2.4
  static const Map<String, String> commonNames = {
    // Prototheria
    'monotremata': 'Monotremes (e.g., Platypus)',

    // Theria
    // Marsupialia
    'didelphimorphia': 'Opossum',
    'paucituberculata': 'Shrew Opossum',
    'microbiotheria': 'Monito del Monte',
    'notoryctemorphia': 'Marsupial Mole',
    'dasyuromorphia': 'Tasmanian Devil',
    'peramelemorphia': 'Bandicoot',
    'diprotodontia': 'Kangaroos, Wallabies & Koalas',

    // Placentalia
    'cingulata': 'Armadillos',
    'pilosa': 'Anteaters & Sloths',
    'macroscelidea': 'Elephant Shrew',
    'afrosoricida': 'Golden Mole',
    'tubulidentata': 'Aardvarks',
    'hyracoidea': 'Hyraxes',
    'proboscidea': 'Elephant',
    'sirenia': 'Manatees & Dugongs',
    'dermoptera': 'Colugo',
    'scandentia': 'Treeshrew',
    'primates': 'Primates',
    'lagomorpha': 'Rabbits, Hares & Pikas',
    'rodentia': 'Rodents',
    'eulipotyphla': 'Hedgehogs, Shrews & Moles',
    'chiroptera': 'Bats',
    'pholidota': 'Pangolin',
    'carnivora': 'Carnivorans',
    'perissodactyla': 'Odd-toed Ungulates',
    'artiodactyla': 'Even-toed Ungulates, Whales & Dolphins',
  };

  String getCommonName(String order) {
    return commonNames[order.toLowerCase()] ?? order;
  }
}

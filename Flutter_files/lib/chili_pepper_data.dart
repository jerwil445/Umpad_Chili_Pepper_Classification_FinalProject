class ChiliPepper {
  final String name;
  final String imagePath;
  final String description;

  ChiliPepper({
    required this.name,
    required this.imagePath,
    required this.description,
  });
}

List<ChiliPepper> getChiliPeppers() {
  return [
    ChiliPepper(
      name: 'Jalapeño',
      imagePath: 'assets/images/Jalapeno.jpg',
      description:
          'The jalapeño is a medium-sized chili pepper pod type commonly produced in Mexico and the United States. It is a cultivar of the species Capsicum annuum. Jalapeños are commonly eaten raw in slices, chopped and mixed with other ingredients, pickled, smoked (known as chipotle), or powdered (known as chili powder). They typically rate between 2,500 and 8,000 Scoville heat units.',
    ),
    ChiliPepper(
      name: 'Habanero',
      imagePath: 'assets/images/Habanero.png',
      description:
          'The habanero is a cultivar of Capsicum chinense. Its shape is generally heart-shaped and slightly pointed at the tip. Habaneros are most commonly orange or red when ripe, but white, brown, yellow, green, or purple varieties also exist. The habanero rates very highly on the Scoville scale, producing a great deal of heat with a rating of 100,000–350,000 SHU.',
    ),
    ChiliPepper(
      name: 'Cayenne',
      imagePath: 'assets/images/Cayenne.jpg',
      description:
          'Cayenne pepper is a type of chili pepper that is used to make cayenne powder, which is a spice. Cayenne peppers are usually a vibrant red color and are typically dried and ground to make the powdered spice. They rate between 30,000 and 50,000 Scoville heat units and are commonly used to season spicy dishes.',
    ),
    ChiliPepper(
      name: 'Serrano',
      imagePath: 'assets/images/Serrano.png',
      description:
          'The serrano pepper is a type of chili pepper that is hotter than the jalapeño. It measures 10,000 to 23,000 Scoville Heat Units. Originating in the mountainous regions of the Mexican states of Puebla and Hidalgo, the name comes from the Spanish word "sierra" (mountain range). Serranos are typically consumed raw in Mexican salsas.',
    ),
    ChiliPepper(
      name: 'Ghost Pepper',
      imagePath: 'assets/images/Ghost_Pepper.jpg',
      description:
          'The ghost pepper, also known as bhut jolokia, is an interspecific hybrid chili pepper cultivated in the Indian states of Arunachal Pradesh, Assam, Nagaland and Manipur. In 2007, Guinness World Records certified that the ghost pepper was the world\'s hottest chili pepper, with 1,001,304 SHU on the Scoville scale.',
    ),
    ChiliPepper(
      name: 'Carolina Reaper',
      imagePath: 'assets/images/Carolina reaper.jpg',
      description:
          'The Carolina Reaper holds the Guinness World Record as the hottest chili pepper in the world. It was developed by Ed Currie in South Carolina and measures over 2 million Scoville Heat Units. The pepper is a cross between a Pakistani Naga and a Red Habanero. It has a distinctive bumpy texture and a sweet-fruity taste that masks its extreme heat.',
    ),
    ChiliPepper(
      name: 'Thai Chili',
      imagePath: 'assets/images/Thai Chili.png',
      description:
          'Thai chilis are small, slender, and very hot chili peppers commonly used in Southeast Asian cuisine. They measure between 50,000 and 100,000 Scoville Heat Units. These peppers are essential ingredients in dishes like pad thai, green curry, and tom yum soup. They are typically used fresh, chopped, or crushed in sauces.',
    ),
    ChiliPepper(
      name: 'Poblano',
      imagePath: 'assets/images/Poblano.png',
      description:
          'The poblano is a mild chili pepper originating in the state of Puebla, Mexico. It is wide, heart-shaped, and has a rich, deep green color when fresh. Poblanos rate between 1,000 and 2,000 Scoville heat units. When dried, the poblano becomes a mulato pepper. They are commonly used in dishes like chiles rellenos and mole poblano.',
    ),
    ChiliPepper(
      name: 'Anaheim',
      imagePath: 'assets/images/Anaheim.png',
      description:
          'Anaheim peppers are mild chili peppers that originated in New Mexico but were brought to Anaheim, California, where they became popular. They rate between 500 and 2,500 Scoville heat units. Anaheims are typically used for stuffing with cheese or meat and are commonly found in dishes like chile relleno and chili con carne.',
    ),
    ChiliPepper(
      name: 'Bird\'s Eye Chili',
      // Using the exact filename with special character
      imagePath: 'assets/images/Bird_s Eye Chili.jpg',
      description:
          'Bird\'s eye chili, also known as Thai chili or bird pepper, is a small chili pepper commonly found in Southeast Asia. Despite its small size, it packs significant heat, measuring between 50,000 and 100,000 Scoville Heat Units. It is widely used in Thai, Vietnamese, Malaysian, and Indonesian cuisines. The pepper gets its name from its small, round shape resembling a bird\'s eye.',
    ),
  ];
}

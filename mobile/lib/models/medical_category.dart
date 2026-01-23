class Category {
  final String icon;
  final String title;

  Category({required this.icon, required this.title});
}

List<Category> medicalCategories = [
  Category(icon: "assets/icons/lungs.svg", title: "Bronquite"),
  Category(icon: "assets/icons/lungs.svg", title: "Pneumonia"),
];

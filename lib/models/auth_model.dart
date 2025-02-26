class Animal {
  String? name;
  int? age;
  int? height;

  Animal({this.name, this.age, this.height});

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      name: json['name'],
      age: json['age'],
      height: json['height']
    );
  }

  Map<String, dynamic> toJson()  {
    return {
      'name' : name,
      'age' : age,
      'height' :height
    };
  }
}
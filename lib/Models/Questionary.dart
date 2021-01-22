class Questionary {
  String name = "";
  String description = "";
  List<QuestionaryFieldType> fields = <QuestionaryFieldType>[];
}

enum QuestionaryFieldAbstract {
  likertScale,
  paragraph,
  multipleChoise,
  singleChoise,
  slider
}

abstract class QuestionaryFieldType {
  QuestionaryFieldAbstract type;
  String key;
  String name;
  String question;
}

class LikertScaleFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.likertScale;
  String key = "likertScale";
  String question = "";
  String name = "Likert Scale";
  List<String> fields = <String>[];
}

class ParagraphFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.paragraph;
  String question = "";
  String name = "Paragraph";
  String key = "paragraph";
}

class MultipleChoiseFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.multipleChoise;
  String key = "multipleChoise";
  String question = "";
  String name = "Multiple Choise";
  List<String> fields = <String>[];
}

class SingleChoiseFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.singleChoise;
  String key = "singleChoise";
  String question = "";
  String name = "Single Choise";
  List<String> fields = <String>[];
}

class SliderFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.slider;
  String key = "slider";
  String question = "";
  String maxValue = "";
  String minValue = "";
  String name = "Slider";
}

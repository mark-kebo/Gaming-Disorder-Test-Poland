import 'package:myapp/Models/Questionary.dart';

class CompletedFormModel {
  String id = "";
  String name = "";
  List<CompletedFormQuestion> questions = <CompletedFormQuestion>[];

  CompletedFormModel(dynamic object) {
    id = object["id"];
    name = object["name"];
    questions = (object["questions"] as List)
        .map((e) => CompletedFormQuestion(e))
        .toList();
  }

  CompletedFormModel.fromQuestionaryModel(QuestionaryModel questionary) {
    this.id = questionary.id;
    this.name = questionary.name;
    this.questions = questionary.questions
        .map((e) => CompletedFormQuestion.fromQuestionaryFieldType(e))
        .toList();
  }

  Map itemsList() {
    return {
      "id": this.id,
      "name": this.name,
      "questions": this.questions.map((e) => e.itemsList()).toList()
    };
  }
}

class CompletedFormQuestion {
  String name = "";
  bool isSoFast = true;
  List<String> selectedOptions = <String>[];

  CompletedFormQuestion(dynamic object) {
    name = object["name"];
    isSoFast = object["isSoFast"];
    selectedOptions =
        (object["selectedOptions"] as List).map((e) => e as String).toList();
  }

  CompletedFormQuestion.fromQuestionaryFieldType(QuestionaryFieldType field) {
    name = field.questionController.text;
  }

  Map itemsList() {
    return {
      "name": this.name,
      "isSoFast": this.isSoFast,
      "selectedOptions": this.selectedOptions.map((e) => e).toList()
    };
  }
}

class SelectedOption {
  String name = "";
  int count = 0;
}
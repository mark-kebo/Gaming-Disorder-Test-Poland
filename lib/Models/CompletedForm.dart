import 'package:myapp/Models/Questionary.dart';

class CompletedFormModel {
  String id = "";
  String name = "";
  bool isSuspicious = false;
  String message = "";
  CompletedCheckList checkList;
  List<CompletedFormQuestion> questions = <CompletedFormQuestion>[];

  CompletedFormModel(dynamic object) {
    id = object["id"];
    name = object["name"];
    message = object["message"];
    isSuspicious = object["isSuspicious"];
    checkList = CompletedCheckList(object["checkList"]);
    questions = (object["questions"] as List)
        .map((e) => CompletedFormQuestion(e))
        .toList();
  }

  CompletedFormModel.fromQuestionaryModel(QuestionaryModel questionary) {
    this.id = questionary.id;
    this.name = questionary.name;
    this.message = questionary.message;
    this.checkList =
        CompletedCheckList.fromQuestionaryModel(questionary.checkList);
    this.questions = questionary.questions
        .map((e) => CompletedFormQuestion.fromQuestionaryFieldType(e))
        .toList();
  }

  Map itemsList() {
    return {
      "id": this.id,
      "name": this.name,
      "message": this.message,
      "isSuspicious": this.isSuspicious,
      "checkList": this.checkList.itemsList(),
      "questions": this.questions.map((e) => e.itemsList()).toList()
    };
  }

  int getPoints() {
    int count = 0;
    questions.forEach((element) {
      count += int.tryParse(element.points) ?? 0;
    });
    return count;
  }
}

class CompletedCheckList {
  String name = "";
  DateTime dateTime;
  Map<String, bool> options = Map<String, bool>();

  CompletedCheckList(dynamic object) {
    if (object != null) {
      name = object["name"];
      dateTime = DateTime.fromMillisecondsSinceEpoch(object["dateTime"] as int);
      (object["options"] as Map<String, dynamic>).forEach((key, value) {
        options[key] = value as bool;
      });
    }
  }

  CompletedCheckList.fromQuestionaryModel(CheckListQuestionaryField object) {
    print("fromQuestionaryModel");
    name = object.nameController.text;
    for (var option in object.optionsControllers) {
      options[option.text] = false;
    }
  }

  Map itemsList() {
    return {
      "name": this.name,
      "dateTime": this.dateTime.millisecondsSinceEpoch,
      "options": this.options
    };
  }
}

class CompletedFormQuestion {
  String name = "";
  bool isSoFast = true;
  String points = "";
  List<String> selectedOptions = <String>[];

  CompletedFormQuestion(dynamic object) {
    name = object["name"];
    points = object["points"];
    isSoFast = object["isSoFast"];
    selectedOptions =
        (object["selectedOptions"] as List).map((e) => e as String).toList();
  }

  CompletedFormQuestion.fromQuestionaryFieldType(QuestionaryFieldType field) {
    name = field.questionController.text;
  }

  Map itemsList() {
    return {
      "points": int.tryParse(this.points) ?? "",
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

import 'package:myapp/Models/Questionary.dart';
import 'package:intl/intl.dart';

class CSVCompletedFormModel {
  String userName;
  String userId;
  CompletedFormModel completedFormModel;

  CSVCompletedFormModel(
      CompletedFormModel model, String userName, String userId) {
    this.completedFormModel = model;
    this.userId = userId;
    this.userName = userName;
  }
}

class CompletedFormModel {
  String id = "";
  String name = "";
  bool isSuspicious = false;
  String message = "";
  int minPoints = 0;
  String dateLogToApp = "";
  bool isOpenFromPush = false;
  String locationData = "";
  String startToAnswerTime;
  CompletedCheckList checkList;
  List<CompletedFormQuestion> questions = <CompletedFormQuestion>[];

  CompletedFormModel(dynamic object) {
    id = object["id"];
    name = object["name"];
    minPoints = object["minPoints"];
    message = object["message"];
    isSuspicious = object["isSuspicious"];
    checkList = CompletedCheckList(object["checkList"]);
    dateLogToApp = object["dateLogToApp"];
    isOpenFromPush = object["isOpenFromPush"];
    locationData = object["locationData"];
    startToAnswerTime = object["startToAnswerTime"];
    questions = (object["questions"] as List)
        .map((e) => CompletedFormQuestion(e))
        .toList();
  }

  CompletedFormModel.fromQuestionaryModel(QuestionaryModel questionary) {
    this.id = questionary.id;
    this.name = questionary.name;
    this.message = questionary.message;
    this.minPoints = int.tryParse(questionary.minPointsToMessage) ?? 0;
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
      "minPoints": this.minPoints,
      "isSuspicious": this.isSuspicious,
      "dateLogToApp": this.dateLogToApp,
      "isOpenFromPush": this.isOpenFromPush,
      "locationData": this.locationData,
      "startToAnswerTime": this.startToAnswerTime,
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
  String uuid = "";
  List<CompletedFormSelectedOptionQuestion> selectedOptions =
      <CompletedFormSelectedOptionQuestion>[];

  CompletedFormQuestion(dynamic object) {
    name = object["name"];
    uuid = object["uuid"];
    isSoFast = object["isSoFast"];
    points = object["points"].toString();
    selectedOptions = (object["selectedOptions"] as List)
        .map((e) => CompletedFormSelectedOptionQuestion.json(e))
        .toList();
  }

  CompletedFormQuestion.fromQuestionaryFieldType(QuestionaryFieldType field) {
    name = field.questionController.text;
  }

  Map itemsList() {
    int optionsPointCount = 0;
    selectedOptions.forEach((element) {
      optionsPointCount += element.points;
    });
    return {
      "uuid": uuid,
      "points": optionsPointCount,
      "name": this.name,
      "isSoFast": this.isSoFast,
      "selectedOptions": this.selectedOptions.map((e) => e.itemsList()).toList()
    };
  }
}

class CompletedFormSelectedOptionQuestion {
  String text = "";
  int points = 0;
  DateTime date;
  int timeSec = 0;
  bool isOther = false;

  String getFullText() {
    return text + "        " + getOptionData();
  }

  String getOptionData() {
    return "(" +
        DateFormat('dd.MM.yyyy HH:mm:ss').format(date) +
        "  -  " +
        timeSec.toString() +
        "sec)";
  }

  CompletedFormSelectedOptionQuestion(String text, String points) {
    this.text = text;
    this.points = int.tryParse(points) ?? 0;
  }

  CompletedFormSelectedOptionQuestion.other(
      String text, String points, bool isOther) {
    this.text = text;
    this.points = int.tryParse(points) ?? 0;
    this.isOther = isOther;
  }

  CompletedFormSelectedOptionQuestion.json(dynamic object) {
    text = object["text"];
    date = DateTime.fromMillisecondsSinceEpoch(object["date"] as int);
    timeSec = object["timeSec"];
  }

  void setTime(int timeSec) {
    this.timeSec = timeSec;
    this.date = DateTime.now();
  }

  Map itemsList() {
    return {
      "text": this.text,
      "date": this.date.millisecondsSinceEpoch,
      "timeSec": this.timeSec
    };
  }
}

class SelectedOption {
  String name = "";
  int count = 0;
}

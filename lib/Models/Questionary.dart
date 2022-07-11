import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionaryModel {
  String id = "";
  String name = "";
  String description = "";
  String groupId = "";
  String groupName = "";
  String message = "";
  String minPointsToMessage = "";
  bool isHasCheckList = false;

  CheckListQuestionaryField checkList = CheckListQuestionaryField.newModel();
  List<QuestionaryFieldType> questions = <QuestionaryFieldType>[];

  QuestionaryModel(String id, DocumentSnapshot snapshot) {
    if (snapshot != null) {
      this.id = id;
      name = snapshot.data()["name"];
      message = snapshot.data()["message"];
      minPointsToMessage = snapshot.data()["minPointsToMessage"];
      isHasCheckList = snapshot.data()["isHasCheckList"];
      description = snapshot.data()["description"];
      groupId = snapshot.data()["groupId"];
      groupName = snapshot.data()["groupName"];
      checkList = CheckListQuestionaryField(snapshot.data()["checkList"]);
      initQuestions(snapshot);
    }
  }

  QuestionaryModel.copyFrom(QuestionaryModel questionary) {
    this.id = questionary.id;
    this.name = questionary.name;
    this.message = questionary.message;
    this.minPointsToMessage = questionary.minPointsToMessage;
    this.description = questionary.name;
    this.groupId = questionary.groupId;
    this.groupName = questionary.groupName;
    this.checkList = questionary.checkList;
    this.isHasCheckList = questionary.isHasCheckList;
    this.questions = questionary.questions.map((e) => e).toList();
  }

  void initQuestions(DocumentSnapshot snapshot) {
    for (var form in snapshot.data()['questions']) {
      var field;
      switch (form["key"]) {
        case "likertScale":
          field = LikertScaleFormField(form);
          break;
        case "paragraph":
          field = ParagraphFormField(form);
          break;
        case "multipleChoise":
          field = MultipleChoiseFormField(form);
          break;
        case "singleChoise":
          field = SingleChoiseFormField(form);
          break;
        case "slider":
          field = SliderFormField(form);
          break;
        case "matrix":
          field = MatrixFormField(form);
          break;
        case "dragAndDrop":
          field = DragAndDropFormField(form);
          break;
      }
      questions.add(field);
    }
  }

  Map<String, dynamic> itemsList(List forms) {
    return {
      'name': this.name,
      'isHasCheckList': this.checkList.nameController.text.isNotEmpty
          ? this.isHasCheckList
          : false,
      'checkList': this.checkList.nameController.text.isNotEmpty
          ? this.checkList.itemsList()
          : null,
      'description': this.description,
      'questions': forms,
      'groupId': this.groupId,
      'groupName': this.groupName,
      'message': this.message,
      'minPointsToMessage': int.tryParse(this.minPointsToMessage ?? "") ?? ""
    };
  }
}

enum QuestionaryFieldAbstract {
  likertScale,
  paragraph,
  multipleChoise,
  singleChoise,
  slider,
  matrix,
  dragAndDrop
}

abstract class QuestionaryFieldType {
  QuestionaryFieldAbstract type;
  String key;
  String name;
  TextEditingController instructionsController = TextEditingController();
  TextEditingController questionController = TextEditingController();
  List<QuestionaryFieldOption> optionsControllers = <QuestionaryFieldOption>[];
  Uint8List image = Uint8List(0);
  Map itemsList();
  Icon icon;
  String keyQuestion = "";
  String keyQuestionOption = "";
  TextEditingController minQuestionTimeController = TextEditingController();

  QuestionaryFieldType createCopy() {
    switch (this.type) {
      case QuestionaryFieldAbstract.likertScale:
        return LikertScaleFormField.copy(this);
        break;
      case QuestionaryFieldAbstract.paragraph:
        return ParagraphFormField.copy(this);
        break;
      case QuestionaryFieldAbstract.multipleChoise:
        return MultipleChoiseFormField.copy(this);
        break;
      case QuestionaryFieldAbstract.singleChoise:
        return SingleChoiseFormField.copy(this);
        break;
      case QuestionaryFieldAbstract.slider:
        return SliderFormField.copy(this);
        break;
      case QuestionaryFieldAbstract.matrix:
        return MatrixFormField.copy(this);
        break;
      case QuestionaryFieldAbstract.dragAndDrop:
        return DragAndDropFormField.copy(this);
        break;
    }
    return this;
  }
}

class QuestionaryFieldOption {
  TextEditingController textController = TextEditingController();
  TextEditingController pointsController = TextEditingController();

  QuestionaryFieldOption(String text, String points) {
    textController.text = text;
    pointsController.text = points;
  }

  QuestionaryFieldOption.from(dynamic item) {
    textController.text = item['text'];
    pointsController.text = item['points'];
  }

  Map itemsList() {
    return {
      "text": this.textController.text,
      "points": this.pointsController.text
    };
  }
}

class MatrixFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.matrix;
  String key = "matrix";
  String name = "Matrix";
  List<TextEditingController> questionsControllers = <TextEditingController>[];
  List<QuestionaryFieldOption> optionsControllers = <QuestionaryFieldOption>[];
  Icon icon = Icon(
    Icons.table_rows_sharp,
    color: Colors.deepPurple,
  );

  MatrixFormField.copy(MatrixFormField questionaryFieldType) {
    this.questionsControllers = questionaryFieldType.questionsControllers
        .map((e) => TextEditingController(text: e.text))
        .toList();
    this.optionsControllers = questionaryFieldType.optionsControllers
        .map((e) => QuestionaryFieldOption(
            e.textController.text, e.pointsController.text))
        .toList();
    this.icon = questionaryFieldType.icon;
    this.keyQuestion = questionaryFieldType.keyQuestion;
    this.keyQuestionOption = questionaryFieldType.keyQuestionOption;
    this.minQuestionTimeController.text =
        questionaryFieldType.minQuestionTimeController.text;
    this.instructionsController.text =
        questionaryFieldType.instructionsController.text;
    this.image = questionaryFieldType.image;
  }

  MatrixFormField(dynamic item) {
    if (item != null) {
      if (item['options'] != null && item['options'] != "null") {
        for (dynamic option in item['options']) {
          optionsControllers.add(QuestionaryFieldOption.from(option));
        }
      }
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      for (var option in item['questions']) {
        var textController = TextEditingController();
        textController.text = option;
        questionsControllers.add(textController);
      }
      minQuestionTimeController =
          TextEditingController(text: item["minTime"].toString());
      instructionsController =
          TextEditingController(text: item["instructions"].toString());
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructionsController.text,
      "key": this.key,
      "questions": this.questionsControllers.map((e) => e.text),
      "name": this.name,
      "options": this.optionsControllers.map((e) => e.itemsList()),
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": int.tryParse(this.minQuestionTimeController.text) ?? 0
    };
  }
}

class LikertScaleFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.likertScale;
  String key = "likertScale";
  TextEditingController questionController = TextEditingController();
  String name = "Likert Scale";
  List<QuestionaryFieldOption> optionsControllers = <QuestionaryFieldOption>[];
  Icon icon = Icon(
    Icons.linear_scale,
    color: Colors.deepPurple,
  );

  LikertScaleFormField.copy(QuestionaryFieldType questionaryFieldType) {
    this.type = questionaryFieldType.type;
    this.key = questionaryFieldType.key;
    this.name = questionaryFieldType.name;
    this.questionController.text = questionaryFieldType.questionController.text;
    this.optionsControllers = questionaryFieldType.optionsControllers
        .map((e) => QuestionaryFieldOption(
            e.textController.text, e.pointsController.text))
        .toList();
    this.icon = questionaryFieldType.icon;
    this.keyQuestion = questionaryFieldType.keyQuestion;
    this.keyQuestionOption = questionaryFieldType.keyQuestionOption;
    this.minQuestionTimeController.text =
        questionaryFieldType.minQuestionTimeController.text;
    this.instructionsController.text =
        questionaryFieldType.instructionsController.text;
    this.image = questionaryFieldType.image;
  }

  LikertScaleFormField(dynamic item) {
    if (item != null) {
      if (item['options'] != null && item['options'] != "null") {
        for (dynamic option in item['options']) {
          optionsControllers.add(QuestionaryFieldOption.from(option));
        }
      }
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      questionController.text = item["question"];
      minQuestionTimeController =
          TextEditingController(text: item["minTime"].toString());
      instructionsController =
          TextEditingController(text: item["instructions"].toString());
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructionsController.text,
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "options": this.optionsControllers.map((e) => e.itemsList()),
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": int.tryParse(this.minQuestionTimeController.text) ?? 0
    };
  }
}

enum ParagraphFormFieldValidationType { text, value }

class ParagraphFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.paragraph;
  TextEditingController questionController = TextEditingController();
  String name = "Paragraph";
  String key = "paragraph";
  Icon icon = Icon(
    Icons.format_align_left_outlined,
    color: Colors.deepPurple,
  );
  String regEx;
  String questionValidationType = "";
  TextEditingController questionValidationSymbols = TextEditingController();

  ParagraphFormField.copy(ParagraphFormField questionaryFieldType) {
    this.type = questionaryFieldType.type;
    this.key = questionaryFieldType.key;
    this.name = questionaryFieldType.name;
    this.questionController.text = questionaryFieldType.questionController.text;
    this.optionsControllers = questionaryFieldType.optionsControllers
        .map((e) => QuestionaryFieldOption(
            e.textController.text, e.pointsController.text))
        .toList();
    this.icon = questionaryFieldType.icon;
    this.keyQuestion = questionaryFieldType.keyQuestion;
    this.keyQuestionOption = questionaryFieldType.keyQuestionOption;
    this.minQuestionTimeController.text =
        questionaryFieldType.minQuestionTimeController.text;
    this.regEx = questionaryFieldType.regEx;
    this.instructionsController.text =
        questionaryFieldType.instructionsController.text;
    this.image = questionaryFieldType.image;
    this.questionValidationType = questionaryFieldType.questionValidationType;
    this.questionValidationSymbols.text =
        questionaryFieldType.questionValidationSymbols.text;
  }

  ParagraphFormField(dynamic item) {
    if (item != null) {
      optionsControllers.add(QuestionaryFieldOption("", ""));
      questionController.text = item["question"];
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      minQuestionTimeController =
          TextEditingController(text: item["minTime"].toString());
      this.regEx = item["regEx"];
      this.questionValidationType = item["validationType"];
      this.questionValidationSymbols =
          TextEditingController(text: item["validationSymbols"].toString());
      instructionsController =
          TextEditingController(text: item["instructions"].toString());
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructionsController.text,
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": int.tryParse(this.minQuestionTimeController.text) ?? 0,
      "regEx": regEx,
      "validationSymbols": this.questionValidationSymbols.text,
      "validationType": this.questionValidationType
    };
  }

  void initRegEx() {
    ParagraphFormFieldValidationType validationType = questionValidationType ==
            ParagraphFormFieldValidationType.text.toString().split('.').last
        ? ParagraphFormFieldValidationType.text
        : ParagraphFormFieldValidationType.value;
    String validationSymbols = questionValidationSymbols.text;
    if (validationSymbols.isEmpty) {
      switch (validationType) {
        case ParagraphFormFieldValidationType.text:
          regEx =
              r'^[(AaĄąBbCcĆćDdEeĘęFfGgHhIiJjKkLlŁłMmNnŃńOoÓóPpRrSsŚśTtUuWwYyZzŹźŻż ,.()?!:;"=)]*$';
          break;
        case ParagraphFormFieldValidationType.value:
          regEx = r'^[(0-9 ,.)]*$';
          break;
      }
    } else {
      regEx = '^[($validationSymbols)]' + r'*$';
    }
  }
}

class DragAndDropFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.dragAndDrop;
  String key = "dragAndDrop";
  TextEditingController questionController = TextEditingController();
  String name = "Ranking";
  Icon icon = Icon(
    Icons.drag_handle_rounded,
    color: Colors.deepPurple,
  );

  DragAndDropFormField.copy(DragAndDropFormField questionaryFieldType) {
    this.type = questionaryFieldType.type;
    this.key = questionaryFieldType.key;
    this.name = questionaryFieldType.name;
    this.questionController.text = questionaryFieldType.questionController.text;
    this.optionsControllers = questionaryFieldType.optionsControllers
        .map((e) => QuestionaryFieldOption(
            e.textController.text, e.pointsController.text))
        .toList();
    this.icon = questionaryFieldType.icon;
    this.keyQuestion = questionaryFieldType.keyQuestion;
    this.keyQuestionOption = questionaryFieldType.keyQuestionOption;
    this.minQuestionTimeController.text =
        questionaryFieldType.minQuestionTimeController.text;
    this.instructionsController.text =
        questionaryFieldType.instructionsController.text;
    this.image = questionaryFieldType.image;
  }

  DragAndDropFormField(dynamic item) {
    if (item != null) {
      if (item['options'] != null && item['options'] != "null") {
        for (dynamic option in item['options']) {
          optionsControllers.add(QuestionaryFieldOption.from(option));
        }
      }
      questionController.text = item["question"];
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      minQuestionTimeController =
          TextEditingController(text: item["minTime"].toString());
      instructionsController =
          TextEditingController(text: item["instructions"].toString());
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructionsController.text,
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "options": this.optionsControllers.map((e) => e.itemsList()),
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": int.tryParse(this.minQuestionTimeController.text) ?? 0
    };
  }
}

class MultipleChoiseFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.multipleChoise;
  String key = "multipleChoise";
  TextEditingController questionController = TextEditingController();
  String name = "Multiple Choise";
  Icon icon = Icon(
    Icons.check_box_outlined,
    color: Colors.deepPurple,
  );
  bool isHasOtherOption = false;

  MultipleChoiseFormField.copy(MultipleChoiseFormField questionaryFieldType) {
    this.type = questionaryFieldType.type;
    this.key = questionaryFieldType.key;
    this.name = questionaryFieldType.name;
    this.questionController.text = questionaryFieldType.questionController.text;
    this.optionsControllers = questionaryFieldType.optionsControllers
        .map((e) => QuestionaryFieldOption(
            e.textController.text, e.pointsController.text))
        .toList();
    this.icon = questionaryFieldType.icon;
    this.keyQuestion = questionaryFieldType.keyQuestion;
    this.keyQuestionOption = questionaryFieldType.keyQuestionOption;
    this.minQuestionTimeController.text =
        questionaryFieldType.minQuestionTimeController.text;
    this.instructionsController.text =
        questionaryFieldType.instructionsController.text;
    this.image = questionaryFieldType.image;
    this.isHasOtherOption = questionaryFieldType.isHasOtherOption;
  }

  MultipleChoiseFormField(dynamic item) {
    if (item != null) {
      if (item['options'] != null && item['options'] != "null") {
        for (dynamic option in item['options']) {
          optionsControllers.add(QuestionaryFieldOption.from(option));
        }
      }
      questionController.text = item["question"];
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      this.isHasOtherOption = item['isHasOtherOption'];
      minQuestionTimeController =
          TextEditingController(text: item["minTime"].toString());
      instructionsController =
          TextEditingController(text: item["instructions"].toString());
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "isHasOtherOption": isHasOtherOption,
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructionsController.text,
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "options": this.optionsControllers.map((e) => e.itemsList()),
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": int.tryParse(this.minQuestionTimeController.text) ?? 0
    };
  }
}

class SingleChoiseFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.singleChoise;
  String key = "singleChoise";
  TextEditingController questionController = TextEditingController();
  String name = "Single Choise";
  Icon icon = Icon(
    Icons.radio_button_checked_outlined,
    color: Colors.deepPurple,
  );
  bool isKeyQuestion = false;

  SingleChoiseFormField.copy(QuestionaryFieldType questionaryFieldType) {
    this.type = questionaryFieldType.type;
    this.key = questionaryFieldType.key;
    this.name = questionaryFieldType.name;
    this.questionController.text = questionaryFieldType.questionController.text;
    this.optionsControllers = questionaryFieldType.optionsControllers
        .map((e) => QuestionaryFieldOption(
            e.textController.text, e.pointsController.text))
        .toList();
    this.icon = questionaryFieldType.icon;
    this.keyQuestion = questionaryFieldType.keyQuestion;
    this.keyQuestionOption = questionaryFieldType.keyQuestionOption;
    this.minQuestionTimeController.text =
        questionaryFieldType.minQuestionTimeController.text;
    this.instructionsController.text =
        questionaryFieldType.instructionsController.text;
    this.image = questionaryFieldType.image;
  }

  SingleChoiseFormField(dynamic item) {
    if (item != null) {
      if (item['options'] != null && item['options'] != "null") {
        for (dynamic option in item['options']) {
          optionsControllers.add(QuestionaryFieldOption.from(option));
        }
      }
      questionController.text = item["question"];
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      isKeyQuestion = item["isKeyQuestion"];
      minQuestionTimeController =
          TextEditingController(text: item["minTime"].toString());
      instructionsController =
          TextEditingController(text: item["instructions"].toString());
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructionsController.text,
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "isKeyQuestion": this.isKeyQuestion,
      "options": this.optionsControllers.map((e) => e.itemsList()),
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "minTime": int.tryParse(this.minQuestionTimeController.text) ?? 0
    };
  }
}

class SliderFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.slider;
  String key = "slider";
  TextEditingController questionController = TextEditingController();
  TextEditingController maxValueController = TextEditingController();
  TextEditingController minValueController = TextEditingController();
  TextEditingController digitStepController = TextEditingController();
  TextEditingController maxDigitController = TextEditingController();
  String name = "Slider";
  Icon icon = Icon(
    Icons.toggle_on_outlined,
    color: Colors.deepPurple,
  );

  SliderFormField.copy(SliderFormField questionaryFieldType) {
    this.type = questionaryFieldType.type;
    this.key = questionaryFieldType.key;
    this.name = questionaryFieldType.name;
    this.questionController.text = questionaryFieldType.questionController.text;
    this.optionsControllers = questionaryFieldType.optionsControllers
        .map((e) => QuestionaryFieldOption(
            e.textController.text, e.pointsController.text))
        .toList();
    this.icon = questionaryFieldType.icon;
    this.keyQuestion = questionaryFieldType.keyQuestion;
    this.keyQuestionOption = questionaryFieldType.keyQuestionOption;
    this.minQuestionTimeController.text =
        questionaryFieldType.minQuestionTimeController.text;
    this.instructionsController.text =
        questionaryFieldType.instructionsController.text;
    this.image = questionaryFieldType.image;
    this.maxValueController.text = questionaryFieldType.maxValueController.text;
    this.maxValueController.text = questionaryFieldType.maxValueController.text;
    this.minValueController.text = questionaryFieldType.minValueController.text;
    this.digitStepController.text =
        questionaryFieldType.digitStepController.text;
    this.maxDigitController.text = questionaryFieldType.maxDigitController.text;
  }

  SliderFormField(dynamic item) {
    if (item != null) {
      optionsControllers.add(QuestionaryFieldOption("", ""));
      maxValueController.text = item["maxValue"];
      minValueController.text = item["minValue"];
      questionController.text = item["question"];
      keyQuestion = item['keyQuestion'];
      keyQuestionOption = item['keyQuestionOption'];
      minQuestionTimeController =
          TextEditingController(text: item["minTime"].toString());
      digitStepController =
          TextEditingController(text: item["digitStep"].toString());
      maxDigitController =
          TextEditingController(text: item["maxDigit"].toString());
      instructionsController =
          TextEditingController(text: item["instructions"].toString());
      if (item["image"] != "null" && item["image"].toString().isNotEmpty) {
        image = Uint8List.fromList(item["image"].toString().codeUnits);
      } else {
        image = Uint8List(0);
      }
    }
  }

  Map itemsList() {
    return {
      "image": String.fromCharCodes(this.image),
      "instructions": this.instructionsController.text,
      "key": this.key,
      "question": this.questionController.text,
      "name": this.name,
      "maxValue": this.maxValueController.text,
      "minValue": this.minValueController.text,
      "keyQuestion": this.keyQuestion,
      "keyQuestionOption": this.keyQuestionOption,
      "digitStep": int.tryParse(this.digitStepController.text) ?? 1,
      "maxDigit": int.tryParse(this.maxDigitController.text) ?? 10,
      "minTime": int.tryParse(this.minQuestionTimeController.text) ?? 0
    };
  }
}

class CheckListQuestionaryField {
  TextEditingController nameController = TextEditingController();
  List<TextEditingController> optionsControllers = <TextEditingController>[];
  Icon icon = Icon(
    Icons.check_circle_rounded,
    color: Colors.deepPurple,
  );

  CheckListQuestionaryField.newModel();

  CheckListQuestionaryField(dynamic item) {
    if (item != null) {
      for (var option in item['options']) {
        var textController = TextEditingController();
        textController.text = option;
        optionsControllers.add(textController);
      }
      nameController.text = item["name"];
    }
  }

  Map itemsList() {
    return {
      "name": this.nameController.text,
      "options": this.optionsControllers.map((e) => e.text),
    };
  }
}

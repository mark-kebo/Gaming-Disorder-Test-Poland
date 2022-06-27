import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionaryModel {
  String id = "";
  String name = "";
  String description = "";
  String groupId = "";
  String groupName = "";
  bool isHasCheckList = false;

  CheckListQuestionaryField checkList = CheckListQuestionaryField.newModel();
  List<QuestionaryFieldType> questions = <QuestionaryFieldType>[];

  QuestionaryModel(String id, DocumentSnapshot snapshot) {
    if (snapshot != null) {
      this.id = id;
      name = snapshot.data()["name"];
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
      }
      questions.add(field);
    }
  }
}

enum QuestionaryFieldAbstract {
  likertScale,
  paragraph,
  multipleChoise,
  singleChoise,
  slider,
  matrix
}

abstract class QuestionaryFieldType {
  QuestionaryFieldAbstract type;
  String key;
  String name;
  TextEditingController instructionsController = TextEditingController();
  TextEditingController questionController = TextEditingController();
  List<TextEditingController> optionsControllers = <TextEditingController>[];
  Uint8List image;
  Map itemsList();
  Icon icon;
  String keyQuestion = "";
  String keyQuestionOption = "";
  TextEditingController minQuestionTimeController = TextEditingController();
}

class MatrixFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.matrix;
  String key = "matrix";
  String name = "Matrix";
  List<TextEditingController> questionsControllers = <TextEditingController>[];
  List<TextEditingController> optionsControllers = <TextEditingController>[];
  Icon icon = Icon(
    Icons.table_rows_sharp,
    color: Colors.deepPurple,
  );

  MatrixFormField.copy(MatrixFormField questionaryFieldType) {
    this.questionsControllers = questionaryFieldType.questionsControllers
        .map((e) => TextEditingController(text: e.text))
        .toList();
    this.optionsControllers = questionaryFieldType.optionsControllers
        .map((e) => TextEditingController(text: e.text))
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
      for (var option in item['options']) {
        var textController = TextEditingController();
        textController.text = option;
        optionsControllers.add(textController);
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
      "options": this.optionsControllers.map((e) => e.text),
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
  List<TextEditingController> optionsControllers = <TextEditingController>[];
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
        .map((e) => TextEditingController(text: e.text))
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
      for (var option in item['options']) {
        var textController = TextEditingController();
        textController.text = option;
        optionsControllers.add(textController);
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
      "options": this.optionsControllers.map((e) => e.text),
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
  List<TextEditingController> optionsControllers = <TextEditingController>[];
  String regEx;
  String questionValidationType = "";
  TextEditingController questionValidationSymbols = TextEditingController();

  ParagraphFormField.copy(ParagraphFormField questionaryFieldType) {
    this.type = questionaryFieldType.type;
    this.key = questionaryFieldType.key;
    this.name = questionaryFieldType.name;
    this.questionController.text = questionaryFieldType.questionController.text;
    this.optionsControllers = questionaryFieldType.optionsControllers
        .map((e) => TextEditingController(text: e.text))
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
  }

  ParagraphFormField(dynamic item) {
    if (item != null) {
      optionsControllers.add(TextEditingController());
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

class MultipleChoiseFormField extends QuestionaryFieldType {
  QuestionaryFieldAbstract type = QuestionaryFieldAbstract.multipleChoise;
  String key = "multipleChoise";
  TextEditingController questionController = TextEditingController();
  String name = "Multiple Choise";
  List<TextEditingController> optionsControllers = <TextEditingController>[];
  Icon icon = Icon(
    Icons.check_box_outlined,
    color: Colors.deepPurple,
  );

  MultipleChoiseFormField.copy(QuestionaryFieldType questionaryFieldType) {
    this.type = questionaryFieldType.type;
    this.key = questionaryFieldType.key;
    this.name = questionaryFieldType.name;
    this.questionController.text = questionaryFieldType.questionController.text;
    this.optionsControllers = questionaryFieldType.optionsControllers
        .map((e) => TextEditingController(text: e.text))
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

  MultipleChoiseFormField(dynamic item) {
    if (item != null) {
      for (var option in item['options']) {
        var textController = TextEditingController();
        textController.text = option;
        optionsControllers.add(textController);
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
      "options": this.optionsControllers.map((e) => e.text),
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
  List<TextEditingController> optionsControllers = <TextEditingController>[];
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
        .map((e) => TextEditingController(text: e.text))
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
      for (var option in item['options']) {
        var textController = TextEditingController();
        textController.text = option;
        optionsControllers.add(textController);
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
      "options": this.optionsControllers.map((e) => e.text),
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
  List<TextEditingController> optionsControllers = <TextEditingController>[];

  SliderFormField.copy(QuestionaryFieldType questionaryFieldType) {
    this.type = questionaryFieldType.type;
    this.key = questionaryFieldType.key;
    this.name = questionaryFieldType.name;
    this.questionController.text = questionaryFieldType.questionController.text;
    this.optionsControllers = questionaryFieldType.optionsControllers
        .map((e) => TextEditingController(text: e.text))
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

  SliderFormField(dynamic item) {
    if (item != null) {
      optionsControllers.add(TextEditingController());
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

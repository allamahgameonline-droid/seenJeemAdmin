import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/question_model.dart';

class ExcelService {
  Future<List<QuestionModel>?> importQuestionsFromExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.bytes != null) {
        var bytes = result.files.single.bytes!;
        var excel = Excel.decodeBytes(bytes);

        List<QuestionModel> questions = [];

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table]!;

          for (var i = 1; i < sheet.maxRows; i++) {
            var row = sheet.row(i);

            if (row.isEmpty || row[0]?.value == null) continue;

            final categoryId = row[0]?.value?.toString() ?? '';
            final question = row[1]?.value?.toString() ?? '';
            final option1 = row[2]?.value?.toString() ?? '';
            final option2 = row[3]?.value?.toString() ?? '';
            final option3 = row[4]?.value?.toString() ?? '';
            final option4 = row[5]?.value?.toString() ?? '';
            final correctAnswer = int.tryParse(row[6]?.value?.toString() ?? '0') ?? 0;
            final difficulty = row[7]?.value?.toString() ?? 'medium';

            questions.add(QuestionModel(
              id: '',
              categoryId: categoryId,
              question: question,
              options: [option1, option2, option3, option4],
              correctAnswer: correctAnswer,
              difficulty: difficulty,
              isActive: true,
              createdAt: DateTime.now(),
            ));
          }
        }

        return questions;
      }
    } catch (e) {
      print('Error importing Excel: $e');
    }
    return null;
  }

  Future<void> exportQuestionsToExcel(List<QuestionModel> questions) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Questions'];

    sheetObject.appendRow([
      const TextCellValue('Category ID'),
      const TextCellValue('Question'),
      const TextCellValue('Option 1'),
      const TextCellValue('Option 2'),
      const TextCellValue('Option 3'),
      const TextCellValue('Option 4'),
      const TextCellValue('Correct Answer'),
      const TextCellValue('Difficulty'),
    ]);

    for (var question in questions) {
      sheetObject.appendRow([
        TextCellValue(question.categoryId),
        TextCellValue(question.question),
        TextCellValue(question.options.isNotEmpty ? question.options[0] : ''),
        TextCellValue(question.options.length > 1 ? question.options[1] : ''),
        TextCellValue(question.options.length > 2 ? question.options[2] : ''),
        TextCellValue(question.options.length > 3 ? question.options[3] : ''),
        IntCellValue(question.correctAnswer),
        TextCellValue(question.difficulty),
      ]);
    }

    var fileBytes = excel.save();
    if (fileBytes != null) {
      print('Excel file created successfully');
    }
  }
}

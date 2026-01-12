import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/firestore_service.dart';
import '../services/excel_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_data_table.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/empty_state.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ExcelService _excelService = ExcelService();
  final _formKey = GlobalKey<FormState>();
  final _categoryIdController = TextEditingController();
  final _questionController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _difficultyController = TextEditingController();
  QuestionModel? _editingQuestion;

  @override
  void dispose() {
    _categoryIdController.dispose();
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _correctAnswerController.dispose();
    _difficultyController.dispose();
    super.dispose();
  }

  void _showQuestionDialog([QuestionModel? question]) {
    _editingQuestion = question;
    if (question != null) {
      _categoryIdController.text = question.categoryId;
      _questionController.text = question.question;
      _option1Controller.text = question.options.isNotEmpty ? question.options[0] : '';
      _option2Controller.text = question.options.length > 1 ? question.options[1] : '';
      _option3Controller.text = question.options.length > 2 ? question.options[2] : '';
      _option4Controller.text = question.options.length > 3 ? question.options[3] : '';
      _correctAnswerController.text = question.correctAnswer.toString();
      _difficultyController.text = question.difficulty;
    } else {
      _categoryIdController.clear();
      _questionController.clear();
      _option1Controller.clear();
      _option2Controller.clear();
      _option3Controller.clear();
      _option4Controller.clear();
      _correctAnswerController.text = '0';
      _difficultyController.text = 'medium';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(question == null ? 'Add Question' : 'Edit Question'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: 'Category ID',
                    controller: _categoryIdController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter category ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Question',
                    controller: _questionController,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter question';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Option 1',
                    controller: _option1Controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter option 1';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Option 2',
                    controller: _option2Controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter option 2';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Option 3',
                    controller: _option3Controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter option 3';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Option 4',
                    controller: _option4Controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter option 4';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Correct Answer (0-3)',
                    controller: _correctAnswerController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter correct answer';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0 || num > 3) {
                        return 'Please enter a number between 0 and 3';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Difficulty',
                    controller: _difficultyController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter difficulty';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Save',
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final questionModel = QuestionModel(
                  id: _editingQuestion?.id ?? '',
                  categoryId: _categoryIdController.text,
                  question: _questionController.text,
                  options: [
                    _option1Controller.text,
                    _option2Controller.text,
                    _option3Controller.text,
                    _option4Controller.text,
                  ],
                  correctAnswer: int.parse(_correctAnswerController.text),
                  difficulty: _difficultyController.text,
                  isActive: _editingQuestion?.isActive ?? true,
                  createdAt: _editingQuestion?.createdAt ?? DateTime.now(),
                );

                if (_editingQuestion == null) {
                  await _firestoreService.addQuestion(questionModel);
                } else {
                  await _firestoreService.updateQuestion(_editingQuestion!.id, questionModel);
                }

                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _importExcel() async {
    final questions = await _excelService.importQuestionsFromExcel();
    if (questions != null) {
      for (var question in questions) {
        await _firestoreService.addQuestion(question);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${questions.length} questions')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Questions',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Row(
                  children: [
                    CustomButton(
                      text: 'Import Excel',
                      icon: Icons.upload_file,
                      onPressed: _importExcel,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: 'Add Question',
                      icon: Icons.add,
                      onPressed: () => _showQuestionDialog(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<QuestionModel>>(
                stream: _firestoreService.getQuestions(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final questions = snapshot.data ?? [];
                  
                  if (questions.isEmpty) {
                    return EmptyState(
                      icon: Icons.help_outline,
                      title: 'No Questions',
                      message: 'Get started by adding your first question or importing from Excel.',
                      action: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                            text: 'Import Excel',
                            icon: Icons.upload_file,
                            onPressed: _importExcel,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          CustomButton(
                            text: 'Add Question',
                            icon: Icons.add,
                            onPressed: () => _showQuestionDialog(),
                          ),
                        ],
                      ),
                    );
                  }

                  final rows = questions.map((question) {
                    return [
                      question.question.length > 50
                          ? '${question.question.substring(0, 50)}...'
                          : question.question,
                      question.categoryId,
                      question.difficulty,
                      question.isActive ? 'Active' : 'Inactive',
                    ];
                  }).toList();

                  return CustomDataTable(
                    columns: const ['Question', 'Category', 'Difficulty', 'Status'],
                    rows: rows,
                    onEdit: (index) => _showQuestionDialog(questions[index]),
                    onDelete: (index) async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Question'),
                          content: const Text('Are you sure you want to delete this question?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _firestoreService.deleteQuestion(questions[index].id);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

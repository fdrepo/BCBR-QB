import '../../app_state.dart';
import 'quiz_actions.dart';
import 'quiz_state.dart';

AppState quizReducer(AppState state, QuizActions action) {
  return action.map(
    loadMcqs: (_) => state,
    loadingMcqs: (action) => _loadingMcqs(state, action),
    loadedMcqs: (action) => _loadedMcqs(state, action),
    select: (action) => _select(state, action),
    submit: (action) => _submit(state, action),
    nextMcq: (action) => _nextMcq(state, action),
  );
}

AppState _loadingMcqs(AppState state, QuizActionsLoadingMcqs action) {
  return state.copyWith(quiz: QuizState.initial());
}

AppState _loadedMcqs(AppState state, QuizActionsLoadedMcqs action) {
  final mcqs = action.mcqs;
  final quiz = mcqs.isNotEmpty
      ? QuizState.initial()
      : QuizState.initial().copyWith(status: QuizStatus.complete);

  return state.copyWith(quiz: quiz.copyWith(tag: action.tag, mcqs: mcqs));
}

AppState _select(AppState state, QuizActionsSelect action) {
  final quiz = state.quiz;
  return state.copyWith(
    quiz: quiz.copyWith(
      selectedAnswers: quiz.selectedAnswers..add(action.answer),
    ),
  );
}

AppState _submit(AppState state, QuizActionsSubmit action) {
  final quiz = state.quiz;

  if (quiz.isCompleted) {
    return state.copyWith(quiz: quiz.copyWith(status: QuizStatus.complete));
  }

  final mcqs = quiz.mcqs;
  if (mcqs == null) return state;

  final currentMcqIndex = quiz.currentMcqIndex;
  final currentQuestion = mcqs[currentMcqIndex];

  final isCorrect = quiz.selectedAnswers.fold<bool>(true, (res, ans) {
    return res && currentQuestion.correctAnswers.contains(ans);
  });

  final correctlyAnsweredMcqIndices = quiz.correctlyAnsweredMcqIndices;
  final incorrectlyAnsweredMcqIndices = quiz.incorrectlyAnsweredMcqIndices;
  if (isCorrect) {
    correctlyAnsweredMcqIndices.add(currentMcqIndex);
  } else {
    incorrectlyAnsweredMcqIndices.add(currentMcqIndex);
  }

  return state.copyWith(
    quiz: quiz.copyWith(
      status: isCorrect ? QuizStatus.correct : QuizStatus.incorrect,
      correctlyAnsweredMcqIndices: correctlyAnsweredMcqIndices,
      incorrectlyAnsweredMcqIndices: incorrectlyAnsweredMcqIndices,
    ),
  );
}

AppState _nextMcq(AppState state, QuizActionsNextMcq action) {
  final quiz = state.quiz;

  final mcqs = quiz.mcqs;
  if (mcqs == null) return state;

  if (quiz.isCompleted) {
    return state.copyWith(quiz: quiz.copyWith(status: QuizStatus.complete));
  }

  return state.copyWith(
    quiz: quiz.copyWith(
      currentMcqIndex: quiz.currentMcqIndex + 1,
      status: QuizStatus.initial,
      selectedAnswers: [],
    ),
  );
}

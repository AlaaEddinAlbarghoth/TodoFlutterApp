import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/cubits/todo_filter/todo_filter_cubit.dart';
import 'package:todo_app/cubits/todo_list/todo_list_cubit.dart';
import 'package:todo_app/cubits/todo_search/todo_search_cubit.dart';
import '../../models/todo_model.dart';

part 'filtered_todos_state.dart';

class FilteredTodosCubit extends Cubit<FilteredTodosState> {
  final TodoListCubit todoListCubit;
  final TodoFilterCubit todoFilterCubit;
  final TodoSearchCubit todoSearchCubit;

  late StreamSubscription todoListSubscription;
  late StreamSubscription todoFilterSubscription;
  late StreamSubscription todoSearchSubscription;

  FilteredTodosCubit(
      {required this.todoListCubit,
      required this.todoFilterCubit,
      required this.todoSearchCubit})
      : super(FilteredTodosState.initial()) {
    todoListSubscription =
        todoListCubit.stream.listen((TodoListState todoListState) {
      setFilterTodos();
    });
    todoFilterSubscription =
        todoFilterCubit.stream.listen((TodoFilterState todoFilterCubit) {
      setFilterTodos();
    });
    todoSearchSubscription =
        todoSearchCubit.stream.listen((TodoSearchState todoSearchState) {
      setFilterTodos();
    });
  }

  void setFilterTodos() {
    List<Todo> filterTodos;

    switch (todoFilterCubit.state.filter) {
      case Filter.all:
        filterTodos = todoListCubit.state.todos;
        break;
      case Filter.active:
        filterTodos = todoListCubit.state.todos
            .where((Todo todo) => !todo.completed)
            .toList();
        break;
      case Filter.completed:
        filterTodos = todoListCubit.state.todos
            .where((Todo todo) => todo.completed)
            .toList();
        break;
    }

    if (todoSearchCubit.state.searchTerm.isNotEmpty) {
      filterTodos = filterTodos
          .where((Todo todo) => todo.desc
              .toLowerCase()
              .contains(todoSearchCubit.state.searchTerm))
          .toList();
    }

    emit(state.copyWith(filteredTodos: filterTodos));
  }

  @override
  Future<void> close() {
    todoListSubscription.cancel();
    todoFilterSubscription.cancel();
    todoSearchSubscription.cancel();
    return super.close();
  }
}

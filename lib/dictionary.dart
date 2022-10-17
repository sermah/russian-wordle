// assets/wordle_complete_dictionary.txt
// assets/wordle_solutions.txt

import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

const alphabet = 'йцукенгшщзхъфывапролджэячсмитьбю'; //= 'abcdefghijklmnopqrstuvwxyz';
const allWordsPath = 'assets/completeRu5Dict.txt'; //= 'assets/wordle_complete_dictionary.txt';
const solutionsPath = 'assets/solutionsRu5.txt'; //= 'assets/wordle_solutions.txt';

class Dictionary {
  late Future<String> _futureCompleteDictionary;
  late Future<String> _futureSolutions;
  late String _completeDictionary;
  late String _solutions;
  Function(String solution) onSolutionLoaded;
  bool _loaded = false;
  bool get loaded => _loaded;

  Future<String> _loadCompleteDict() async {
    return rootBundle.loadString(allWordsPath);
  }

  Future<String> _loadSolutions() async {
    return rootBundle.loadString(solutionsPath);
  }

  Future _loadAll() async {
    _futureCompleteDictionary = _loadCompleteDict();
    _futureSolutions = _loadSolutions();
    var results = Future.wait([_futureCompleteDictionary, _futureSolutions]);
    results.then((value) {
      _completeDictionary = value[0];
      _solutions = value[1];
      _loaded = true;
      onSolutionLoaded(pickSolution());
    }, onError: (_){ print('Not loaded'); });
  }

  Dictionary(this.onSolutionLoaded) {
    _loadAll();
  }

  String pickSolution() {
    var pos = Random().nextInt(_solutions.length ~/ 7) * 7;
    return _solutions.substring(pos, pos+5);
  }

  bool wordIsInDict(String word) {
    word = word.toLowerCase();
    var equals = false;
    for ( var i = 0; i < _completeDictionary.length-5 && !equals; i+=7){
      equals = true;
      for (var j = 0; j < 5; j++) {
        if (_completeDictionary[i+j] != word[j]) {
          equals = false;
          break;
        }
      }
    }
    return equals;
  }
}



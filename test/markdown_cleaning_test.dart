import 'package:flutter_test/flutter_test.dart';

// Copie de la méthode _cleanResponseForTTS pour les tests
String cleanResponseForTTS(String response) {
  // Supprimer tout ce qui est entre parenthèses
  String cleaned = response.replaceAll(RegExp(r'\([^)]*\)'), '');
  
  // Supprimer les marqueurs markdown en préservant le contenu
  cleaned = cleaned
      // Gras **texte** - garder seulement le texte
      .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '')
      .replaceAllMapped(RegExp(r'__(.*?)__'), (match) => match.group(1) ?? '')
      // Italique *texte* - attention aux conflits avec les listes
      .replaceAllMapped(RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'), (match) => match.group(1) ?? '')
      .replaceAllMapped(RegExp(r'(?<!_)_([^_]+)_(?!_)'), (match) => match.group(1) ?? '')
      // Code `texte`
      .replaceAllMapped(RegExp(r'`([^`]*)`'), (match) => match.group(1) ?? '')
      // Liens [texte](url) - garder seulement le texte
      .replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]*\)'), (match) => match.group(1) ?? '')
      // Barré ~~texte~~
      .replaceAllMapped(RegExp(r'~~(.*?)~~'), (match) => match.group(1) ?? '')
      // Titres # ## ### etc. - enlever seulement les #
      .replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '')
      // Listes - ou * ou + - enlever seulement les puces
      .replaceAll(RegExp(r'^[\s]*[-*+]\s+', multiLine: true), '')
      // Listes numérotées 1. 2. etc.
      .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '')
      // Citations >
      .replaceAll(RegExp(r'^>\s*', multiLine: true), '')
      // Code blocks ``` - supprimer entièrement
      .replaceAll(RegExp(r'```[^`]*```', dotAll: true), '');
  
  // Supprimer les caractères indésirables d'abord
  cleaned = cleaned
      .replaceAll(RegExp(r'[\$]+'), '') // Supprimer les $ qui trainent
      .replaceAll(RegExp(r'\*+'), '') // Supprimer les * isolés
      .replaceAll(RegExp(r'"+'), '') // Supprimer les " isolés
      .replaceAll(RegExp(r'\s+'), ' ') // Puis nettoyer les espaces multiples
      .trim();
  
  return cleaned;
}

void main() {
  group('Markdown Cleaning Tests', () {
    test('Test suppression markdown gras **texte**', () {
      // Test principal demandé
      String input = 'coucou **toto** lala';
      String expected = 'coucou toto lala';
      String result = cleanResponseForTTS(input);
      
      print('Input: "$input"');
      print('Expected: "$expected"');
      print('Result: "$result"');
      
      expect(result, equals(expected));
    });

    test('Test suppression gras avec __texte__', () {
      String input = 'hello __world__ test';
      String expected = 'hello world test';
      String result = cleanResponseForTTS(input);
      
      expect(result, equals(expected));
    });

    test('Test suppression italique *texte*', () {
      String input = 'hello *world* test';
      String expected = 'hello world test';
      String result = cleanResponseForTTS(input);
      
      expect(result, equals(expected));
    });

    test('Test suppression code `texte`', () {
      String input = 'run `flutter test` command';
      String expected = 'run flutter test command';
      String result = cleanResponseForTTS(input);
      
      expect(result, equals(expected));
    });

    test('Test suppression liens [texte](url)', () {
      String input = 'visit [Google](https://google.com) site';
      String expected = 'visit Google site';
      String result = cleanResponseForTTS(input);
      
      expect(result, equals(expected));
    });

    test('Test suppression parenthèses (contenu)', () {
      String input = 'hello (this should be removed) world';
      String expected = 'hello  world';
      String result = cleanResponseForTTS(input);
      
      // Après nettoyage des espaces multiples
      expect(result, equals('hello world'));
    });

    test('Test multiple markdown dans une phrase', () {
      String input = 'Voici **du gras** et *de l\'italique* avec `du code` et [un lien](url.com)';
      String expected = 'Voici du gras et de l\'italique avec du code et un lien';
      String result = cleanResponseForTTS(input);
      
      expect(result, equals(expected));
    });

    test('Test avec caractères \$ parasites', () {
      String input = 'hello \\\$ world \\\$\\\$ test';
      String expected = 'hello world test';
      String result = cleanResponseForTTS(input);
      
      expect(result, equals(expected));
    });

    test('Test texte sans markdown', () {
      String input = 'Ceci est un texte normal sans markdown';
      String expected = 'Ceci est un texte normal sans markdown';
      String result = cleanResponseForTTS(input);
      
      expect(result, equals(expected));
    });

    test('Test chaîne vide', () {
      String input = '';
      String expected = '';
      String result = cleanResponseForTTS(input);
      
      expect(result, equals(expected));
    });

    test('Test suppression * isolés', () {
      String input = 'hello * world ** test *';
      String expected = 'hello world test';
      String result = cleanResponseForTTS(input);
      
      expect(result, equals(expected));
    });

    test('Test suppression " isolées', () {
      String input = 'hello " world "" test "';
      String expected = 'hello world test';
      String result = cleanResponseForTTS(input);
      
      expect(result, equals(expected));
    });

    test('Test suppression * et " combinées', () {
      String input = 'hello * " world " * test';
      String expected = 'hello world test';
      String result = cleanResponseForTTS(input);
      
      expect(result, equals(expected));
    });
  });
}
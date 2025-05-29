import 'package:flutter/material.dart';

class LanguageConfig {
  final String speechToTextLocale;
  final String ttsLanguage;
  final String aiSystemPrompt;
  final String aiSummarizePrompt;

  const LanguageConfig({
    required this.speechToTextLocale,
    required this.ttsLanguage,
    required this.aiSystemPrompt,
    required this.aiSummarizePrompt,
  });

  static LanguageConfig french() => const LanguageConfig(
    speechToTextLocale: 'fr-FR',
    ttsLanguage: 'fr-FR',
    aiSystemPrompt: 'Tu es un assistant vocal intelligent et serviable. '
        'Réponds de manière concise et naturelle en français. '
        'Adapte ton ton selon le contexte de la conversation.',
    aiSummarizePrompt: 'Résume ce texte en exactement 100 mots maximum pour une réponse vocale, '
        'en gardant les informations les plus importantes comme les noms propres. '
        'Ensuite, propose 2-3 questions courtes pour approfondir le sujet. '
        'Format: [RÉSUMÉ] suivi de [QUESTIONS] avec les questions numérotées : ',
  );

  static LanguageConfig english() => const LanguageConfig(
    speechToTextLocale: 'en-US',
    ttsLanguage: 'en-US',
    aiSystemPrompt: 'You are an intelligent and helpful voice assistant. '
        'Respond concisely and naturally in English. '
        'Adapt your tone according to the conversation context.',
    aiSummarizePrompt: 'Summarize this text in exactly 100 words maximum for a voice response, '
        'keeping the most important information like proper names. '
        'Then, suggest 2-3 short questions to deepen the subject. '
        'Format: [SUMMARY] followed by [QUESTIONS] with numbered questions: ',
  );

  static LanguageConfig japanese() => const LanguageConfig(
    speechToTextLocale: 'ja-JP',
    ttsLanguage: 'ja-JP',
    aiSystemPrompt: 'あなたは賢くて親切な音声アシスタントです。'
        '日本語で簡潔で自然に応答してください。'
        '会話の文脈に応じて口調を調整してください。',
    aiSummarizePrompt: '音声応答用にこのテキストを最大100語で要約し、'
        '固有名詞などの重要な情報を保持してください。'
        'その後、話題を深めるための短い質問を2-3個提案してください。'
        'フォーマット：[要約]の後に[質問]を番号付きで：',
  );

  static LanguageConfig spanish() => const LanguageConfig(
    speechToTextLocale: 'es-ES',
    ttsLanguage: 'es-ES',
    aiSystemPrompt: 'Eres un asistente de voz inteligente y útil. '
        'Responde de manera concisa y natural en español. '
        'Adapta tu tono según el contexto de la conversación.',
    aiSummarizePrompt: 'Resume este texto en exactamente 100 palabras máximo para una respuesta de voz, '
        'manteniendo la información más importante como nombres propios. '
        'Luego, sugiere 2-3 preguntas cortas para profundizar el tema. '
        'Formato: [RESUMEN] seguido de [PREGUNTAS] con preguntas numeradas: ',
  );

  static LanguageConfig italian() => const LanguageConfig(
    speechToTextLocale: 'it-IT',
    ttsLanguage: 'it-IT',
    aiSystemPrompt: 'Sei un assistente vocale intelligente e utile. '
        'Rispondi in modo conciso e naturale in italiano. '
        'Adatta il tuo tono secondo il contesto della conversazione.',
    aiSummarizePrompt: 'Riassumi questo testo in esattamente 100 parole massimo per una risposta vocale, '
        'mantenendo le informazioni più importanti come i nomi propri. '
        'Poi, suggerisci 2-3 domande brevi per approfondire l\'argomento. '
        'Formato: [RIASSUNTO] seguito da [DOMANDE] con domande numerate: ',
  );

  static LanguageConfig german() => const LanguageConfig(
    speechToTextLocale: 'de-DE',
    ttsLanguage: 'de-DE',
    aiSystemPrompt: 'Du bist ein intelligenter und hilfreicher Sprachassistent. '
        'Antworte prägnant und natürlich auf Deutsch. '
        'Passe deinen Ton an den Kontext des Gesprächs an.',
    aiSummarizePrompt: 'Fasse diesen Text in genau maximal 100 Wörtern für eine Sprachantwort zusammen, '
        'behalte die wichtigsten Informationen wie Eigennamen bei. '
        'Dann schlage 2-3 kurze Fragen vor, um das Thema zu vertiefen. '
        'Format: [ZUSAMMENFASSUNG] gefolgt von [FRAGEN] mit nummerierten Fragen: ',
  );

  static LanguageConfig chinese() => const LanguageConfig(
    speechToTextLocale: 'zh-CN',
    ttsLanguage: 'zh-CN',
    aiSystemPrompt: '你是一个智能且有用的语音助手。'
        '请用中文简洁自然地回答。'
        '根据对话语境调整你的语调。',
    aiSummarizePrompt: '将此文本总结为语音回答，最多100个字，'
        '保留最重要的信息如专有名词。'
        '然后建议2-3个简短问题来深入探讨主题。'
        '格式：[摘要]后跟[问题]带编号的问题：',
  );

  static LanguageConfig fromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return english();
      case 'ja':
        return japanese();
      case 'es':
        return spanish();
      case 'it':
        return italian();
      case 'de':
        return german();
      case 'zh':
        return chinese();
      case 'fr':
      default:
        return french();
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageConfig &&
          runtimeType == other.runtimeType &&
          speechToTextLocale == other.speechToTextLocale &&
          ttsLanguage == other.ttsLanguage &&
          aiSystemPrompt == other.aiSystemPrompt &&
          aiSummarizePrompt == other.aiSummarizePrompt;

  @override
  int get hashCode =>
      speechToTextLocale.hashCode ^
      ttsLanguage.hashCode ^
      aiSystemPrompt.hashCode ^
      aiSummarizePrompt.hashCode;
}
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Sentinel default for the widgets' string parameters.
///
/// It means "the caller didn't pass anything — use the localized default",
/// which is different from `null` (the caller explicitly wants to hide this
/// element). It's an internal detail; you never need to reference it.
const String kFesUseDefault = '￿__fes.default__';

/// Resolves a widget string: a sentinel falls through to [fallback], an
/// explicit `null` means "hide", anything else is used verbatim.
String? resolveFesString(String? value, String fallback) =>
    identical(value, kFesUseDefault) ? fallback : value;

/// The translatable strings used by the flutter_empty_state widgets.
///
/// The widgets fall back to English automatically, so the package works with
/// zero setup. To translate them, register the [delegate] and the locales you
/// support in your `MaterialApp`:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: const [
///     EmptyStateLocalizations.delegate,
///     ...GlobalMaterialLocalizations.delegates,
///   ],
///   supportedLocales: EmptyStateLocalizations.supportedLocales,
/// )
/// ```
///
/// Need a language that isn't bundled? Subclass this, return your strings, and
/// provide it through your own [LocalizationsDelegate] — or send a PR.
abstract class EmptyStateLocalizations {
  const EmptyStateLocalizations();

  /// Looks up the localizations for [context], falling back to English when no
  /// [delegate] is registered. Never returns null, so widgets can use it
  /// unconditionally.
  static EmptyStateLocalizations of(BuildContext context) {
    return Localizations.of<EmptyStateLocalizations>(
          context,
          EmptyStateLocalizations,
        ) ??
        const EmptyStateLocalizationsEn();
  }

  /// Add this to your app's `localizationsDelegates`.
  static const LocalizationsDelegate<EmptyStateLocalizations> delegate =
      _EmptyStateLocalizationsDelegate();

  /// The locales this package ships translations for. Unlisted locales fall
  /// back to English.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('uz'),
    Locale('ru'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('pt'),
    Locale('tr'),
    Locale('ar'),
    Locale('zh'),
  ];

  /// Default [EmptyState] title.
  String get emptyTitle;

  /// Default [ErrorState] title.
  String get errorTitle;

  /// Default [ErrorState] message.
  String get errorMessage;

  /// Default label for retry / action buttons.
  String get retryButtonLabel;

  /// Default [NoInternetState] title.
  String get noInternetTitle;

  /// Default [NoInternetState] message.
  String get noInternetMessage;

  /// Default [SearchEmptyState] title.
  String get searchEmptyTitle;

  /// Default [SearchEmptyState] clear-button label.
  String get clearSearchButtonLabel;

  /// Default "Details" disclosure label on [ErrorState].
  String get detailsLabel;

  /// [SearchEmptyState] message when there's no query to mention.
  String get searchTryDifferent;

  /// [SearchEmptyState] message built from the user's [query].
  String searchNoMatches(String query);
}

EmptyStateLocalizations _lookupEmptyStateLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'uz':
      return const EmptyStateLocalizationsUz();
    case 'ru':
      return const EmptyStateLocalizationsRu();
    case 'es':
      return const EmptyStateLocalizationsEs();
    case 'fr':
      return const EmptyStateLocalizationsFr();
    case 'de':
      return const EmptyStateLocalizationsDe();
    case 'pt':
      return const EmptyStateLocalizationsPt();
    case 'tr':
      return const EmptyStateLocalizationsTr();
    case 'ar':
      return const EmptyStateLocalizationsAr();
    case 'zh':
      return const EmptyStateLocalizationsZh();
    case 'en':
    default:
      return const EmptyStateLocalizationsEn();
  }
}

class _EmptyStateLocalizationsDelegate
    extends LocalizationsDelegate<EmptyStateLocalizations> {
  const _EmptyStateLocalizationsDelegate();

  // Return true for every locale so we always provide an English fallback
  // rather than letting lookups fail for unsupported languages.
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<EmptyStateLocalizations> load(Locale locale) {
    return SynchronousFuture<EmptyStateLocalizations>(
      _lookupEmptyStateLocalizations(locale),
    );
  }

  @override
  bool shouldReload(_EmptyStateLocalizationsDelegate old) => false;
}

/// English (default).
class EmptyStateLocalizationsEn extends EmptyStateLocalizations {
  const EmptyStateLocalizationsEn();

  @override
  String get emptyTitle => 'Nothing here yet';
  @override
  String get errorTitle => 'Something went wrong';
  @override
  String get errorMessage => 'Please try again later.';
  @override
  String get retryButtonLabel => 'Retry';
  @override
  String get noInternetTitle => 'No internet connection';
  @override
  String get noInternetMessage => 'Please check your connection and try again.';
  @override
  String get searchEmptyTitle => 'No results found';
  @override
  String get clearSearchButtonLabel => 'Clear search';
  @override
  String get detailsLabel => 'Details';
  @override
  String get searchTryDifferent => 'Try a different search.';
  @override
  String searchNoMatches(String query) => 'No matches for "$query".';
}

/// Uzbek.
class EmptyStateLocalizationsUz extends EmptyStateLocalizations {
  const EmptyStateLocalizationsUz();

  @override
  String get emptyTitle => 'Hozircha bu yerda hech narsa yo\'q';
  @override
  String get errorTitle => 'Nimadir xato ketdi';
  @override
  String get errorMessage => 'Iltimos, keyinroq qayta urinib ko\'ring.';
  @override
  String get retryButtonLabel => 'Qayta urinish';
  @override
  String get noInternetTitle => 'Internet aloqasi yo\'q';
  @override
  String get noInternetMessage =>
      'Iltimos, aloqani tekshirib, qayta urinib ko\'ring.';
  @override
  String get searchEmptyTitle => 'Hech narsa topilmadi';
  @override
  String get clearSearchButtonLabel => 'Qidiruvni tozalash';
  @override
  String get detailsLabel => 'Tafsilotlar';
  @override
  String get searchTryDifferent => 'Boshqacha qidirib ko\'ring.';
  @override
  String searchNoMatches(String query) =>
      '"$query" bo\'yicha hech narsa topilmadi.';
}

/// Russian.
class EmptyStateLocalizationsRu extends EmptyStateLocalizations {
  const EmptyStateLocalizationsRu();

  @override
  String get emptyTitle => 'Здесь пока ничего нет';
  @override
  String get errorTitle => 'Что-то пошло не так';
  @override
  String get errorMessage => 'Пожалуйста, повторите попытку позже.';
  @override
  String get retryButtonLabel => 'Повторить';
  @override
  String get noInternetTitle => 'Нет подключения к интернету';
  @override
  String get noInternetMessage => 'Проверьте соединение и повторите попытку.';
  @override
  String get searchEmptyTitle => 'Ничего не найдено';
  @override
  String get clearSearchButtonLabel => 'Очистить поиск';
  @override
  String get detailsLabel => 'Подробности';
  @override
  String get searchTryDifferent => 'Попробуйте изменить запрос.';
  @override
  String searchNoMatches(String query) => 'Нет совпадений для «$query».';
}

/// Spanish.
class EmptyStateLocalizationsEs extends EmptyStateLocalizations {
  const EmptyStateLocalizationsEs();

  @override
  String get emptyTitle => 'Aún no hay nada aquí';
  @override
  String get errorTitle => 'Algo salió mal';
  @override
  String get errorMessage => 'Inténtalo de nuevo más tarde.';
  @override
  String get retryButtonLabel => 'Reintentar';
  @override
  String get noInternetTitle => 'Sin conexión a internet';
  @override
  String get noInternetMessage => 'Comprueba tu conexión e inténtalo de nuevo.';
  @override
  String get searchEmptyTitle => 'No se encontraron resultados';
  @override
  String get clearSearchButtonLabel => 'Borrar búsqueda';
  @override
  String get detailsLabel => 'Detalles';
  @override
  String get searchTryDifferent => 'Prueba con otra búsqueda.';
  @override
  String searchNoMatches(String query) => 'No hay coincidencias para «$query».';
}

/// French.
class EmptyStateLocalizationsFr extends EmptyStateLocalizations {
  const EmptyStateLocalizationsFr();

  @override
  String get emptyTitle => 'Rien ici pour le moment';
  @override
  String get errorTitle => 'Une erreur s\'est produite';
  @override
  String get errorMessage => 'Veuillez réessayer plus tard.';
  @override
  String get retryButtonLabel => 'Réessayer';
  @override
  String get noInternetTitle => 'Pas de connexion internet';
  @override
  String get noInternetMessage => 'Vérifiez votre connexion et réessayez.';
  @override
  String get searchEmptyTitle => 'Aucun résultat trouvé';
  @override
  String get clearSearchButtonLabel => 'Effacer la recherche';
  @override
  String get detailsLabel => 'Détails';
  @override
  String get searchTryDifferent => 'Essayez une autre recherche.';
  @override
  String searchNoMatches(String query) => 'Aucun résultat pour « $query ».';
}

/// German.
class EmptyStateLocalizationsDe extends EmptyStateLocalizations {
  const EmptyStateLocalizationsDe();

  @override
  String get emptyTitle => 'Noch nichts hier';
  @override
  String get errorTitle => 'Etwas ist schiefgelaufen';
  @override
  String get errorMessage => 'Bitte versuchen Sie es später erneut.';
  @override
  String get retryButtonLabel => 'Erneut versuchen';
  @override
  String get noInternetTitle => 'Keine Internetverbindung';
  @override
  String get noInternetMessage =>
      'Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';
  @override
  String get searchEmptyTitle => 'Keine Ergebnisse gefunden';
  @override
  String get clearSearchButtonLabel => 'Suche löschen';
  @override
  String get detailsLabel => 'Details';
  @override
  String get searchTryDifferent => 'Versuchen Sie eine andere Suche.';
  @override
  String searchNoMatches(String query) => 'Keine Treffer für „$query".';
}

/// Portuguese.
class EmptyStateLocalizationsPt extends EmptyStateLocalizations {
  const EmptyStateLocalizationsPt();

  @override
  String get emptyTitle => 'Ainda não há nada aqui';
  @override
  String get errorTitle => 'Algo deu errado';
  @override
  String get errorMessage => 'Tente novamente mais tarde.';
  @override
  String get retryButtonLabel => 'Tentar novamente';
  @override
  String get noInternetTitle => 'Sem conexão com a internet';
  @override
  String get noInternetMessage => 'Verifique sua conexão e tente novamente.';
  @override
  String get searchEmptyTitle => 'Nenhum resultado encontrado';
  @override
  String get clearSearchButtonLabel => 'Limpar busca';
  @override
  String get detailsLabel => 'Detalhes';
  @override
  String get searchTryDifferent => 'Tente uma busca diferente.';
  @override
  String searchNoMatches(String query) => 'Nenhum resultado para "$query".';
}

/// Turkish.
class EmptyStateLocalizationsTr extends EmptyStateLocalizations {
  const EmptyStateLocalizationsTr();

  @override
  String get emptyTitle => 'Burada henüz bir şey yok';
  @override
  String get errorTitle => 'Bir şeyler ters gitti';
  @override
  String get errorMessage => 'Lütfen daha sonra tekrar deneyin.';
  @override
  String get retryButtonLabel => 'Yeniden dene';
  @override
  String get noInternetTitle => 'İnternet bağlantısı yok';
  @override
  String get noInternetMessage =>
      'Lütfen bağlantınızı kontrol edip tekrar deneyin.';
  @override
  String get searchEmptyTitle => 'Sonuç bulunamadı';
  @override
  String get clearSearchButtonLabel => 'Aramayı temizle';
  @override
  String get detailsLabel => 'Ayrıntılar';
  @override
  String get searchTryDifferent => 'Farklı bir arama deneyin.';
  @override
  String searchNoMatches(String query) => '"$query" için eşleşme yok.';
}

/// Arabic.
class EmptyStateLocalizationsAr extends EmptyStateLocalizations {
  const EmptyStateLocalizationsAr();

  @override
  String get emptyTitle => 'لا يوجد شيء هنا بعد';
  @override
  String get errorTitle => 'حدث خطأ ما';
  @override
  String get errorMessage => 'يرجى المحاولة مرة أخرى لاحقًا.';
  @override
  String get retryButtonLabel => 'إعادة المحاولة';
  @override
  String get noInternetTitle => 'لا يوجد اتصال بالإنترنت';
  @override
  String get noInternetMessage => 'يرجى التحقق من اتصالك والمحاولة مرة أخرى.';
  @override
  String get searchEmptyTitle => 'لم يتم العثور على نتائج';
  @override
  String get clearSearchButtonLabel => 'مسح البحث';
  @override
  String get detailsLabel => 'التفاصيل';
  @override
  String get searchTryDifferent => 'جرّب بحثًا مختلفًا.';
  @override
  String searchNoMatches(String query) => 'لا توجد نتائج لـ "$query".';
}

/// Chinese (Simplified).
class EmptyStateLocalizationsZh extends EmptyStateLocalizations {
  const EmptyStateLocalizationsZh();

  @override
  String get emptyTitle => '这里还没有内容';
  @override
  String get errorTitle => '出了点问题';
  @override
  String get errorMessage => '请稍后再试。';
  @override
  String get retryButtonLabel => '重试';
  @override
  String get noInternetTitle => '无网络连接';
  @override
  String get noInternetMessage => '请检查您的网络连接后重试。';
  @override
  String get searchEmptyTitle => '未找到结果';
  @override
  String get clearSearchButtonLabel => '清除搜索';
  @override
  String get detailsLabel => '详情';
  @override
  String get searchTryDifferent => '试试其他搜索。';
  @override
  String searchNoMatches(String query) => '没有找到"$query"的结果。';
}

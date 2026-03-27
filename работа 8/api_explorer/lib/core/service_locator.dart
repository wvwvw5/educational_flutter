import 'package:get_it/get_it.dart';
import 'dio_client.dart';
import '../features/animals/animal_repository.dart';
import '../features/jokes/joke_repository.dart';
import '../features/quotes/quote_repository.dart';
import '../features/facts/fact_repository.dart';
import '../features/recipes/recipe_repository.dart';

final getIt = GetIt.instance;

/// Registers all dependencies using get_it.
void setupServiceLocator() {
  // Core
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Repositories
  getIt.registerLazySingleton<AnimalRepository>(
    () => AnimalRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<JokeRepository>(
    () => JokeRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<QuoteRepository>(
    () => QuoteRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<FactRepository>(
    () => FactRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<RecipeRepository>(
    () => RecipeRepository(getIt<DioClient>()),
  );
}

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# CloseShare App Development Instructions

This is the CloseShare app - a smart closet sharing application built with Flutter and Clean Architecture structure. Please follow these guidelines when generating code:

## Project Structure
- `lib/core/` - Core functionality (DI, network, storage, theme)
- `lib/features/` - Feature modules with presentation/domain/data layers
- `lib/shared/` - Shared widgets and utilities
- `assets/` - Images, icons, fonts

## State Management
- Use BLoC pattern for state management
- Use Cubit for simple state management
- Follow BLoC naming conventions (Event, State, Bloc)

## API Integration
- Use Dio for HTTP requests
- API client is already configured in `core/network/`
- Handle errors appropriately with try-catch blocks

## Styling & Theming
- Use the predefined theme in `core/theme/app_theme.dart`
- Follow Material Design 3 guidelines
- Use custom widgets from `shared/widgets/` when possible

## Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add proper comments for complex logic
- Use const constructors where possible

## Dependencies Already Available
- flutter_bloc: State management
- dio: HTTP client
- get_it: Dependency injection
- shared_preferences & hive: Local storage
- cached_network_image: Image caching
- flutter_svg: SVG support

## Vietnamese Language Support
- Use Vietnamese text for user-facing content
- Support UTF-8 encoding for Vietnamese characters
